//
//  WBSettingViewController.m
//  WeChatRedEnvelop
//
//  Created by 杨志超 on 2017/2/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import "WBSettingViewController.h"
#import "WeChatRedEnvelop.h"
#import "WBRedEnvelopConfig.h"
#import <objc/objc-runtime.h>

@interface WBSettingViewController () <MultiSelectContactsViewControllerDelegate>

@property (nonatomic, strong) WCTableViewManager *tableViewMgr;

@end

@implementation WBSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _tableViewMgr = [[objc_getClass("WCTableViewManager") alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTitle];
    [self reloadTableData];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;

    MMTableView *tableView = [self.tableViewMgr getTableView];
    [self.view addSubview:tableView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopLoading];
}

- (void)initTitle {
    self.title = @"微信小助手";
}

- (void)reloadTableData {
    [self.tableViewMgr clearAllSection];
    
    [self addBasicSettingSection];
    [self addSupportSection];
    
    CContactMgr *contactMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:objc_getClass("CContactMgr")];
    
    if ([contactMgr isInContactList:@"gh_6e8bddcdfca3"]) {
        [self addAdvanceSettingSection];
    } else {
        [self addAdvanceLimitSection];
    }
    
    [self addAboutSection];
    
    MMTableView *tableView = [self.tableViewMgr getTableView];
    [tableView reloadData];
}

#pragma mark - BasicSetting

- (void)addBasicSettingSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoDefaut];
    
    [sectionInfo addCell:[self createAutoReceiveRedEnvelopCell]];
    [sectionInfo addCell:[self createDelaySettingCell]];
    
    [self.tableViewMgr addSection:sectionInfo];
}

- (WCTableViewCellManager *)createAutoReceiveRedEnvelopCell {
    return [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(switchRedEnvelop:) target:self title:@"自动抢红包" on:[WBRedEnvelopConfig sharedConfig].autoReceiveEnable];
}

- (WCTableViewCellManager *)createDelaySettingCell {
    NSInteger delaySeconds = [WBRedEnvelopConfig sharedConfig].delaySeconds;
    NSString *delayString = delaySeconds == 0 ? @"不延迟" : [NSString stringWithFormat:@"%ld 秒", (long)delaySeconds];
    
    WCTableViewCellManager *cellInfo = nil;
    if ([WBRedEnvelopConfig sharedConfig].autoReceiveEnable) {
        cellInfo = [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(settingDelay) target:self title:@"延迟抢红包" rightValue:delayString WithDisclosureIndicator:1];
    } else {
        cellInfo = [objc_getClass("WCTableViewNormalCellManager") normalCellForTitle:@"延迟抢红包" rightValue: @"抢红包已关闭"];
    }
    return cellInfo;
}

- (void)switchRedEnvelop:(UISwitch *)envelopSwitch {
    [WBRedEnvelopConfig sharedConfig].autoReceiveEnable = envelopSwitch.on;
    
    [self reloadTableData];
}

- (void)settingDelay {
    UIAlertView *alert = [UIAlertView new];
    alert.title = @"延迟抢红包(秒)";
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert addButtonWithTitle:@"取消"];
    [alert addButtonWithTitle:@"确定"];
    
    [alert textFieldAtIndex:0].placeholder = @"延迟时长";
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *delaySecondsString = [alertView textFieldAtIndex:0].text;
        NSInteger delaySeconds = [delaySecondsString integerValue];
        
        [WBRedEnvelopConfig sharedConfig].delaySeconds = delaySeconds;
        
        [self reloadTableData];
    }
}

#pragma mark - ProSetting
- (void)addAdvanceSettingSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoHeader:@"高级功能"];
    
    [sectionInfo addCell:[self createReceiveSelfRedEnvelopCell]];
    [sectionInfo addCell:[self createQueueCell]];
    [sectionInfo addCell:[self createBlackListCell]];
    [sectionInfo addCell:[self createAbortRemokeMessageCell]];
    [sectionInfo addCell:[self createKeywordFilterCell]];
    
    [self.tableViewMgr addSection:sectionInfo];
}

- (WCTableViewCellManager *)createReceiveSelfRedEnvelopCell {
    return [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(settingReceiveSelfRedEnvelop:) target:self title:@"抢自己发的红包" on:[WBRedEnvelopConfig sharedConfig].receiveSelfRedEnvelop];
}

- (WCTableViewCellManager *)createQueueCell {
    return [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(settingReceiveByQueue:) target:self title:@"防止同时抢多个红包" on:[WBRedEnvelopConfig sharedConfig].serialReceive];
}

- (WCTableViewCellManager *)createBlackListCell {
    
    if ([WBRedEnvelopConfig sharedConfig].blackList.count == 0) {
        return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(showBlackList) target:self title:@"群聊过滤" rightValue:@"已关闭" WithDisclosureIndicator:1];
    } else {
        NSString *blackListCountStr = [NSString stringWithFormat:@"已选 %lu 个群", (unsigned long)[WBRedEnvelopConfig sharedConfig].blackList.count];
        return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(showBlackList) target:self title:@"群聊过滤" rightValue:blackListCountStr WithDisclosureIndicator:1];
    }
    
}

- (WCTableViewSectionManager *)createAbortRemokeMessageCell {
    return [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(settingMessageRevoke:) target:self title:@"消息防撤回" on:[WBRedEnvelopConfig sharedConfig].revokeEnable];
}

- (WCTableViewSectionManager *)createKeywordFilterCell {
    return [objc_getClass("WCTableViewNormalCellManager") normalCellForTitle:@"关键词过滤" rightValue:@"开发中..."];
}

- (void)settingReceiveSelfRedEnvelop:(UISwitch *)receiveSwitch {
    [WBRedEnvelopConfig sharedConfig].receiveSelfRedEnvelop = receiveSwitch.on;
}

- (void)settingReceiveByQueue:(UISwitch *)queueSwitch {
    [WBRedEnvelopConfig sharedConfig].serialReceive = queueSwitch.on;
}

- (void)showBlackList {
    MultiSelectContactsViewController *contactsViewController = [[objc_getClass("MultiSelectContactsViewController") alloc] init];
    contactsViewController.m_scene = 5;
    contactsViewController.m_delegate = self;

    // 强制触发 viewDidLoad 调用
    if ([contactsViewController respondsToSelector:@selector(loadViewIfNeeded)]) {
        [contactsViewController loadViewIfNeeded];
    } else {
        contactsViewController.view.alpha = 1.0;
    }

    MMServiceCenter *serviceCenter = [objc_getClass("MMServiceCenter") defaultCenter];
    CContactMgr *contactMgr = [serviceCenter getService:objc_getClass("CContactMgr")];
        
    ContactSelectView *selectView = (ContactSelectView *)[contactsViewController valueForKey:@"m_selectView"];
    for (NSString *contactName in [WBRedEnvelopConfig sharedConfig].blackList) {
        CContact *contact = [contactMgr getContactByName:contactName];
        [selectView addSelect:contact];
    }
    [contactsViewController updatePanelBtn];

    MMUINavigationController *navigationController = [[objc_getClass("MMUINavigationController") alloc] initWithRootViewController:contactsViewController];

    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)settingMessageRevoke:(UISwitch *)revokeSwitch {
    [WBRedEnvelopConfig sharedConfig].revokeEnable = revokeSwitch.on;
}

#pragma mark - ProLimit

- (void)addAdvanceLimitSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoHeader:@"高级功能" Footer:@"关注公众号后开启高级功能"];
    
    [sectionInfo addCell:[self createReceiveSelfRedEnvelopLimitCell]];
    [sectionInfo addCell:[self createQueueLimitCell]];
    [sectionInfo addCell:[self createBlackListLimitCell]];
    [sectionInfo addCell:[self createAbortRemokeMessageLimitCell]];
    [sectionInfo addCell:[self createKeywordFilterLimitCell]];
    
    [self.tableViewMgr addSection:sectionInfo];
}

- (WCTableViewCellManager *)createReceiveSelfRedEnvelopLimitCell {
    return [objc_getClass("WCTableViewNormalCellManager") normalCellForTitle:@"抢自己发的红包" rightValue:@"未启用"];
}

- (WCTableViewCellManager *)createQueueLimitCell {
    return [objc_getClass("WCTableViewNormalCellManager") normalCellForTitle:@"防止同时抢多个红包" rightValue:@"未启用"];
}

- (WCTableViewCellManager *)createBlackListLimitCell {
    return [objc_getClass("WCTableViewNormalCellManager") normalCellForTitle:@"群聊过滤" rightValue:@"未启用"];
}

- (WCTableViewSectionManager *)createKeywordFilterLimitCell {
    return [objc_getClass("WCTableViewNormalCellManager") normalCellForTitle:@"关键词过滤" rightValue:@"未启用"];
}

- (WCTableViewSectionManager *)createAbortRemokeMessageLimitCell {
    return [objc_getClass("WCTableViewNormalCellManager") normalCellForTitle:@"消息防撤回" rightValue:@"未启用"];
}

#pragma mark - About
- (void)addAboutSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoDefaut];
    
    [sectionInfo addCell:[self createGithubCell]];
    [sectionInfo addCell:[self createBlogCell]];
    
    [self.tableViewMgr addSection:sectionInfo];
}

- (WCTableViewCellManager *)createGithubCell {
    return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(showGithub) target:self title:@"我的 Github" rightValue: @"★ star" WithDisclosureIndicator:1];
}

- (WCTableViewCellManager *)createBlogCell {
    return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(showBlog) target:self title:@"我的博客"];
}

- (void)showGithub {
    NSURL *gitHubUrl = [NSURL URLWithString:@"https://github.com/buginux/WeChatRedEnvelop"];
    MMWebViewController *webViewController = [[objc_getClass("MMWebViewController") alloc] initWithURL:gitHubUrl presentModal:NO extraInfo:nil];
    [self.navigationController PushViewController:webViewController animated:YES];
}

- (void)showBlog {
    NSURL *blogUrl = [NSURL URLWithString:@"http://www.swiftyper.com"];
    MMWebViewController *webViewController = [[objc_getClass("MMWebViewController") alloc] initWithURL:blogUrl presentModal:NO extraInfo:nil];
    [self.navigationController PushViewController:webViewController animated:YES];
}

#pragma mark - Support
- (void)addSupportSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoDefaut];
    
    [sectionInfo addCell:[self createWeChatPayingCell]];
    
    [self.tableViewMgr addSection:sectionInfo];
}

- (WCTableViewCellManager *)createWeChatPayingCell {
    return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(payingToAuthor) target:self title:@"微信打赏" rightValue:@"支持作者开发" WithDisclosureIndicator:1];
}

- (void)payingToAuthor {
    [self startLoadingNonBlock];
    ScanQRCodeLogicController *scanQRCodeLogic = [[objc_getClass("ScanQRCodeLogicController") alloc] initWithViewController:self CodeType:31];
    scanQRCodeLogic.fromScene = 1;
    
    NewQRCodeScanner *qrCodeScanner = [[objc_getClass("NewQRCodeScanner") alloc] initWithDelegate:scanQRCodeLogic CodeType:31];

    NSString *rewardStr = @"m0#tYKR_$YKjkz~7IjWLFL";
    NSData *rewardData = [rewardStr dataUsingEncoding:4];  
    [qrCodeScanner notifyResult:rewardStr type:@"WX_CODE" version:0 rawData:rewardData];
}

#pragma mark - MultiSelectContactsViewControllerDelegate

- (void)onMultiSelectContactReturn:(NSArray *)arg1 {
    NSMutableArray *blackList = [NSMutableArray new];
    for (CContact *contact in arg1) {
        NSString *contactName = contact.m_nsUsrName;
        if ([contactName length] > 0 && [contactName hasSuffix:@"@chatroom"]) {
            [blackList addObject:contactName];
        }
    }
    [WBRedEnvelopConfig sharedConfig].blackList = blackList;
    [self reloadTableData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
