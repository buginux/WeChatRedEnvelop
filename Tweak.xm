#import "WeChatRedEnvelop.h"

%hook CMessageMgr
- (void)AsyncOnAddMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap {
	%orig;
	
	switch(wrap.m_uiMessageType) {
	case 49: { // AppNode

		CContactMgr *contactManager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CContactMgr") class]];
		CContact *selfContact = [contactManager getSelfContact];

		BOOL isMesasgeFromMe = NO;
		if ([wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName]) {
			isMesasgeFromMe = YES;
		}

		if ([wrap.m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound) { // 红包
			
			// 是否打开红包开关
			BOOL redEnvelopSwitchOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"XGWeChatRedEnvelopSwitchKey"];

			// 群聊中，别人发红包
			BOOL redEnvelopInChatRoomFromOther = ([wrap.m_nsFromUsr rangeOfString:@"@chatroom"].location != NSNotFound);
			
			// 群聊中，自己发红包
			BOOL redEnvelopInChatRoomFromMe = (isMesasgeFromMe && ([wrap.m_nsToUsr rangeOfString:@"@chatroom"].location != NSNotFound));

			if (redEnvelopSwitchOn && (redEnvelopInChatRoomFromOther || redEnvelopInChatRoomFromMe)) {

				NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
				nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];

				NSDictionary *nativeUrlDict = [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeUrl separator:@"&"];

				/** 构造参数 */
				NSMutableDictionary *params = [@{} mutableCopy];
				params[@"msgType"] = nativeUrlDict[@"msgtype"] ?: @"1";
				params[@"sendId"] = nativeUrlDict[@"sendid"] ?: @"";
				params[@"channelId"] = nativeUrlDict[@"channelid"] ?: @"1";
				params[@"nickName"] = [selfContact getContactDisplayName] ?: @"小锅";
				params[@"headImg"] = [selfContact m_nsHeadImgUrl] ?: @"";
				params[@"nativeUrl"] = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl] ?: @"";
				params[@"sessionUserName"] = redEnvelopInChatRoomFromMe ? wrap.m_nsToUsr : wrap.m_nsFromUsr;

				WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];
				[logicMgr OpenRedEnvelopesRequest:params];
			}
		}	
		break;
	}
	default:
		break;
	}
	
}
%end

%hook NewSettingViewController

- (void)reloadTableData {
	%orig;

	MMTableViewInfo *tableViewInfo = MSHookIvar<id>(self, "m_tableViewInfo");

	MMTableViewSectionInfo *sectionInfo = [%c(MMTableViewSectionInfo) sectionInfoDefaut];
	
	BOOL redEnvelopSwitchOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"XGWeChatRedEnvelopSwitchKey"];
	MMTableViewCellInfo *cellInfo = [%c(MMTableViewCellInfo) switchCellForSel:@selector(switchRedEnvelop:) target:self title:@"抢红包开关" on:redEnvelopSwitchOn];
	[sectionInfo addCell:cellInfo];

	[tableViewInfo insertSection:sectionInfo At:0];	

	MMTableView *tableView = [tableViewInfo getTableView];
	[tableView reloadData];
}

%new
- (void)switchRedEnvelop:(UISwitch *)envelopSwitch {
	NSString *kRedEnvelopSwitchKey = @"XGWeChatRedEnvelopSwitchKey";

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (envelopSwitch.on) {
    	[defaults setBool:YES forKey:kRedEnvelopSwitchKey];
	} else {
		[defaults setBool:NO forKey:kRedEnvelopSwitchKey];
	}
}

%end


