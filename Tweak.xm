#import "WeChatRedEnvelop.h"

%hook CMessageMgr
- (void)AsyncOnAddMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap {
	%orig;
	
	if (!yb_shouldStart) {return;}
	float delayTime = (float)arc4random_uniform(yb_delayTime) + 0.1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		switch(wrap.m_uiMessageType) {
		case 49: { // AppNode

			CContactMgr *contactManager = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("CContactMgr") class]];
			CContact *selfContact = [contactManager getSelfContact];

			BOOL isMesasgeFromMe = NO;
			if ([wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName]) {
				isMesasgeFromMe = YES;
			}

			if ([wrap.m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound) { // 红包
				if ([wrap.m_nsFromUsr rangeOfString:@"@chatroom"].location != NSNotFound ||
					(isMesasgeFromMe && [wrap.m_nsToUsr rangeOfString:@"@chatroom"].location != NSNotFound)) { // 群组红包或群组里自己发的红包

					NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
					nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];

					NSDictionary *nativeUrlDict = [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeUrl separator:@"&"];

					/** 构造参数 */
					NSMutableDictionary *params = [@{} mutableCopy];
					[params safeSetObject:nativeUrlDict[@"msgtype"] forKey:@"msgType"];
					[params safeSetObject:nativeUrlDict[@"sendid"] forKey:@"sendId"];
					[params safeSetObject:nativeUrlDict[@"channelid"] forKey:@"channelId"];
					[params safeSetObject:[selfContact getContactDisplayName] forKey:@"nickName"];
					[params safeSetObject:[selfContact m_nsHeadImgUrl] forKey:@"headImg"];
					[params safeSetObject:[[wrap m_oWCPayInfoItem] m_c2cNativeUrl] forKey:@"nativeUrl"];
					[params safeSetObject:msg forKey:@"sessionUserName"];	

					WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];
					[logicMgr OpenRedEnvelopesRequest:params];
				}
			}	
			break;
		}
		default:
			break;
		}
    });
}
%end

%hook SettingPluginsViewController
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2{
	if (arg2 == 0) {
		yb_cellNumber = %orig ;
		return %orig + 1; 
	} //帮第一组加一行 其他的不处理
	return %orig;
}

- (id)tableView:(UITableView *)arg1 cellForRowAtIndexPath:(NSIndexPath *)arg2{
	if (arg2.section != 0) {return %orig;} // 非第一组直接返回
	//判断是否是自己添加多出来的那一行
	if (arg2.row != yb_cellNumber)  {return %orig;} 

	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingPluginsViewController"];
    // cell.imageView.image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LuckyMoney_RoundBtn@2x" ofType:@"png"]];
    cell.textLabel.text = @"          自动抢红包";
    [cell.textLabel setFont:[UIFont systemFontOfSize:17]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor whiteColor];
	return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.section != 0) {%orig;} // 非第一组直接返回
	//判断是否是自己添加多出来的那一行
	if (indexPath.row != yb_cellNumber) {%orig;}


	UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"是否开启自动抢红包"  message:nil preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"终止" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
               yb_shouldStart = NO;
    }];
    
    UIAlertAction *beginAction = [UIAlertAction actionWithTitle:@"开始" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               yb_shouldStart = YES;
               yb_delayTime = 0;
    }];
    
    UIAlertAction *delay10SecsAction = [UIAlertAction actionWithTitle:@"10秒内开抢" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               yb_shouldStart = YES;
               yb_delayTime = 10;
    }];
    
    UIAlertAction *delay30SecsAction = [UIAlertAction actionWithTitle:@"30秒内开抢" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
               yb_shouldStart = YES;
               yb_delayTime = 30;
    }];

    [alertVc addAction:beginAction];
    [alertVc addAction:delay10SecsAction];
    [alertVc addAction:delay30SecsAction];
    [alertVc addAction:cancelAction];
   [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVc animated:YES completion:nil];

}

%end
