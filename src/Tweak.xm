#import "WeChatRedEnvelop.h"
#import "WeChatRedEnvelopParam.h"
#import "WBSettingViewController.h"
#import "WBReceiveRedEnvelopOperation.h"
#import "WBRedEnvelopTaskManager.h"
#import "WBRedEnvelopConfig.h"
#import "WBRedEnvelopParamQueue.h"

%hook MicroMessengerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  		
  	CContactMgr *contactMgr = [[%c(MMServiceCenter) defaultCenter] getService:%c(CContactMgr)];
	CContact *contact = [contactMgr getContactForSearchByName:@"gh_6e8bddcdfca3"];
	if (contact) {
	    [contactMgr addLocalContact:contact listType:2];
    	[contactMgr getContactsFromServer:@[contact]];
	}

	return %orig;
}
%end

%hook WCRedEnvelopesLogicMgr

- (void)OnWCToHongbaoCommonResponse:(HongBaoRes *)arg1 Request:(HongBaoReq *)arg2 {

	%orig;

	// 非参数查询请求
	if (arg1.cgiCmdid != 3) { return; }

	NSString *(^parseRequestSign)() = ^NSString *() {
		NSString *requestString = [[NSString alloc] initWithData:arg2.reqText.buffer encoding:NSUTF8StringEncoding];
		NSDictionary *requestDictionary = [%c(WCBizUtil) dictionaryWithDecodedComponets:requestString separator:@"&"];
		NSString *nativeUrl = [[requestDictionary stringForKey:@"nativeUrl"] stringByRemovingPercentEncoding];
		NSDictionary *nativeUrlDict = [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeUrl separator:@"&"];

		return [nativeUrlDict stringForKey:@"sign"];
	};

	NSDictionary *responseDict = [[[NSString alloc] initWithData:arg1.retText.buffer encoding:NSUTF8StringEncoding] JSONDictionary];

	WeChatRedEnvelopParam *mgrParams = [[WBRedEnvelopParamQueue sharedQueue] dequeue];

	BOOL (^shouldReceiveRedEnvelop)() = ^BOOL() {

		// 手动抢红包
		if (!mgrParams) { return NO; }

		// 自己已经抢过
		if ([responseDict[@"receiveStatus"] integerValue] == 2) { return NO; }

		// 红包被抢完
		if ([responseDict[@"hbStatus"] integerValue] == 4) { return NO; }		

		// 没有这个字段会被判定为使用外挂
		if (!responseDict[@"timingIdentifier"]) { return NO; }		

		if (mgrParams.isGroupSender) { // 自己发红包的时候没有 sign 字段
			return [WBRedEnvelopConfig sharedConfig].autoReceiveEnable;
		} else {
			return [parseRequestSign() isEqualToString:mgrParams.sign] && [WBRedEnvelopConfig sharedConfig].autoReceiveEnable;
		}
	};

	if (shouldReceiveRedEnvelop()) {
		mgrParams.timingIdentifier = responseDict[@"timingIdentifier"];

		unsigned int delaySeconds = [self calculateDelaySeconds];
		WBReceiveRedEnvelopOperation *operation = [[WBReceiveRedEnvelopOperation alloc] initWithRedEnvelopParam:mgrParams delay:delaySeconds];

		if ([WBRedEnvelopConfig sharedConfig].serialReceive) {
			[[WBRedEnvelopTaskManager sharedManager] addSerialTask:operation];
		} else {
			[[WBRedEnvelopTaskManager sharedManager] addNormalTask:operation];
		}
	}
}

%new
- (unsigned int)calculateDelaySeconds {
	NSInteger configDelaySeconds = [WBRedEnvelopConfig sharedConfig].delaySeconds;

	if ([WBRedEnvelopConfig sharedConfig].serialReceive) {
		unsigned int serialDelaySeconds;
		if ([WBRedEnvelopTaskManager sharedManager].serialQueueIsEmpty) {
			serialDelaySeconds = configDelaySeconds;
		} else {
			serialDelaySeconds = 15;
		}

		return serialDelaySeconds;
	} else {
		return (unsigned int)configDelaySeconds;
	}
}

%end

%hook CMessageMgr
- (void)AsyncOnAddMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap {
	%orig;
	
	switch(wrap.m_uiMessageType) {
	case 49: { // AppNode

		/** 是否为红包消息 */
		BOOL (^isRedEnvelopMessage)() = ^BOOL() {
			return [wrap.m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound;
		};
		
		if (isRedEnvelopMessage()) { // 红包
			CContactMgr *contactManager = [[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]];
			CContact *selfContact = [contactManager getSelfContact];

			BOOL (^isSender)() = ^BOOL() {
				return [wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName];
			};

			/** 是否别人在群聊中发消息 */
			BOOL (^isGroupReceiver)() = ^BOOL() {
				return [wrap.m_nsFromUsr rangeOfString:@"@chatroom"].location != NSNotFound;
			};

			/** 是否自己在群聊中发消息 */
			BOOL (^isGroupSender)() = ^BOOL() {
				return isSender() && [wrap.m_nsToUsr rangeOfString:@"chatroom"].location != NSNotFound;
			};

			/** 是否抢自己发的红包 */
			BOOL (^isReceiveSelfRedEnvelop)() = ^BOOL() {
				return [WBRedEnvelopConfig sharedConfig].receiveSelfRedEnvelop;
			};

			/** 是否在黑名单中 */
			BOOL (^isGroupInBlackList)() = ^BOOL() {
				return [[WBRedEnvelopConfig sharedConfig].blackList containsObject:wrap.m_nsFromUsr];
			};

			/** 是否自动抢红包 */
			BOOL (^shouldReceiveRedEnvelop)() = ^BOOL() {
				if (![WBRedEnvelopConfig sharedConfig].autoReceiveEnable) { return NO; }
				if (isGroupInBlackList()) { return NO; }

				return isGroupReceiver() || (isGroupSender() && isReceiveSelfRedEnvelop());
			};

			NSDictionary *(^parseNativeUrl)(NSString *nativeUrl) = ^(NSString *nativeUrl) {
				nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
				return [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
			};

			/** 获取服务端验证参数 */
			void (^queryRedEnvelopesReqeust)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
				NSMutableDictionary *params = [@{} mutableCopy];
				params[@"agreeDuty"] = @"0";
				params[@"channelId"] = [nativeUrlDict stringForKey:@"channelid"];
				params[@"inWay"] = @"0";
				params[@"msgType"] = [nativeUrlDict stringForKey:@"msgtype"];
				params[@"nativeUrl"] = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
				params[@"sendId"] = [nativeUrlDict stringForKey:@"sendid"];

				WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];
				[logicMgr ReceiverQueryRedEnvelopesRequest:params];
			};

			/** 储存参数 */
			void (^enqueueParam)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
					WeChatRedEnvelopParam *mgrParams = [[WeChatRedEnvelopParam alloc] init];
					mgrParams.msgType = [nativeUrlDict stringForKey:@"msgtype"];
					mgrParams.sendId = [nativeUrlDict stringForKey:@"sendid"];
					mgrParams.channelId = [nativeUrlDict stringForKey:@"channelid"];
					mgrParams.nickName = [selfContact getContactDisplayName];
					mgrParams.headImg = [selfContact m_nsHeadImgUrl];
					mgrParams.nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
					mgrParams.sessionUserName = isGroupSender() ? wrap.m_nsToUsr : wrap.m_nsFromUsr;
					mgrParams.sign = [nativeUrlDict stringForKey:@"sign"];

					mgrParams.isGroupSender = isGroupSender();

					[[WBRedEnvelopParamQueue sharedQueue] enqueue:mgrParams];
			};

			if (shouldReceiveRedEnvelop()) {
				NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];			
				NSDictionary *nativeUrlDict = parseNativeUrl(nativeUrl);

				queryRedEnvelopesReqeust(nativeUrlDict);
				enqueueParam(nativeUrlDict);
			}
		}	
		break;
	}
	default:
		break;
	}
	
}

- (void)onRevokeMsg:(CMessageWrap *)arg1 {

	if (![WBRedEnvelopConfig sharedConfig].revokeEnable) {
		%orig;
	} else {
		if ([arg1.m_nsContent rangeOfString:@"<session>"].location == NSNotFound) { return; }
		if ([arg1.m_nsContent rangeOfString:@"<replacemsg>"].location == NSNotFound) { return; }

		NSString *(^parseSession)() = ^NSString *() {
			NSUInteger startIndex = [arg1.m_nsContent rangeOfString:@"<session>"].location + @"<session>".length;
			NSUInteger endIndex = [arg1.m_nsContent rangeOfString:@"</session>"].location;
			NSRange range = NSMakeRange(startIndex, endIndex - startIndex);
			return [arg1.m_nsContent substringWithRange:range];
		};

		NSString *(^parseSenderName)() = ^NSString *() {
		    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<!\\[CDATA\\[(.*?)撤回了一条消息\\]\\]>" options:NSRegularExpressionCaseInsensitive error:nil];

		    NSRange range = NSMakeRange(0, arg1.m_nsContent.length);
		    NSTextCheckingResult *result = [regex matchesInString:arg1.m_nsContent options:0 range:range].firstObject;
		    if (result.numberOfRanges < 2) { return nil; }

		    return [arg1.m_nsContent substringWithRange:[result rangeAtIndex:1]];
		};

		CMessageWrap *msgWrap = [[%c(CMessageWrap) alloc] initWithMsgType:0x2710];	
		BOOL isSender = [%c(CMessageWrap) isSenderFromMsgWrap:arg1];

		NSString *sendContent;
		if (isSender) {
			[msgWrap setM_nsFromUsr:arg1.m_nsToUsr];
			[msgWrap setM_nsToUsr:arg1.m_nsFromUsr];
			sendContent = @"你撤回一条消息";
		} else {
			[msgWrap setM_nsToUsr:arg1.m_nsToUsr];
			[msgWrap setM_nsFromUsr:arg1.m_nsFromUsr];

			NSString *name = parseSenderName();
			sendContent = [NSString stringWithFormat:@"拦截 %@ 的一条撤回消息", name ? name : arg1.m_nsFromUsr];
		}
		[msgWrap setM_uiStatus:0x4];
		[msgWrap setM_nsContent:sendContent];
		[msgWrap setM_uiCreateTime:[arg1 m_uiCreateTime]];

		[self AddLocalMsg:parseSession() MsgWrap:msgWrap fixTime:0x1 NewMsgArriveNotify:0x0];
	}
}

%end

%hook NewSettingViewController

- (void)reloadTableData {
	%orig;

	WCTableViewManager *tableViewMgr = MSHookIvar<id>(self, "m_tableViewMgr");

	WCTableViewSectionManager *sectionInfo = [%c(WCTableViewSectionManager) sectionInfoDefaut];

	WCTableViewCellManager *settingCell = [%c(WCTableViewCellManager) normalCellForSel:@selector(setting) target:self title:@"微信小助手"];
	[sectionInfo addCell:settingCell];

	CContactMgr *contactMgr = [[%c(MMServiceCenter) defaultCenter] getService:%c(CContactMgr)];

	NSString *rightValue = @"未关注";
	if ([contactMgr isInContactList:@"gh_6e8bddcdfca3"]) {
		rightValue = @"已关注";
	} else {
		rightValue = @"未关注";
		CContact *contact = [contactMgr getContactForSearchByName:@"gh_6e8bddcdfca3"];
		[contactMgr addLocalContact:contact listType:2];
		[contactMgr getContactsFromServer:@[contact]];
	}

	WCTableViewCellManager *followOfficalAccountCell = [%c(WCTableViewCellManager) normalCellForSel:@selector(followMyOfficalAccount) target:self title:@"关注我的公众号" rightValue:rightValue WithDisclosureIndicator:1];
	[sectionInfo addCell:followOfficalAccountCell];

	[tableViewMgr insertSection:sectionInfo At:0];

	MMTableView *tableView = [tableViewMgr getTableView];
	[tableView reloadData];
}

%new
- (void)setting {
	WBSettingViewController *settingViewController = [WBSettingViewController new];
	[self.navigationController PushViewController:settingViewController animated:YES];
}

%new
- (void)followMyOfficalAccount {
	CContactMgr *contactMgr = [[%c(MMServiceCenter) defaultCenter] getService:%c(CContactMgr)];

	CContact *contact = [contactMgr getContactByName:@"gh_6e8bddcdfca3"];

	ContactInfoViewController *contactViewController = [[%c(ContactInfoViewController) alloc] init];
	[contactViewController setM_contact:contact];

	[self.navigationController PushViewController:contactViewController animated:YES]; 
}

%end
