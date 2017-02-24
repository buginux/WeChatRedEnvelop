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
#import "WBMultiSelectGroupsViewController.h"

@interface WBSettingViewController () <MultiSelectContactsViewControllerDelegate, MultiSelectGroupsViewControllerDelegate>

@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;

@end

@implementation WBSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _tableViewInfo = [[objc_getClass("MMTableViewInfo") alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadTableData];
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [self.view addSubview:tableView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopLoading];
}

- (void)reloadTableData {
    [self.tableViewInfo clearAllSection];
    
    [self addBasicSettingSection];
    [self addAdvanceSettingSection];
    [self addSupportSection];
    [self addAboutSection];
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}

#pragma mark - BasicSetting

- (void)addBasicSettingSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoDefaut];
    
    [sectionInfo addCell:[self createAutoReceiveRedEnvelopCell]];
    
    if ([WBRedEnvelopConfig sharedConfig].autoReceiveEnable) {
        [sectionInfo addCell:[self createDelaySettingCell]];
    }
    
    [self.tableViewInfo addSection:sectionInfo];
}


- (MMTableViewCellInfo *)createAutoReceiveRedEnvelopCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(switchRedEnvelop:) target:self title:@"自动抢红包" on:[WBRedEnvelopConfig sharedConfig].autoReceiveEnable];
}

- (MMTableViewCellInfo *)createDelaySettingCell {
    NSInteger delaySeconds = [WBRedEnvelopConfig sharedConfig].delaySeconds;
    return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingDelay) target:self title:@"延迟抢红包" rightValue:[NSString stringWithFormat:@"%ld 秒", (long)delaySeconds] accessoryType:1];
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
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"高级功能"];
    
    [sectionInfo addCell:[self createQueueCell]];
    [sectionInfo addCell:[self createBlackListCell]];
    [sectionInfo addCell:[self createComingSoonCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewCellInfo *)createQueueCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingReceiveByQueue:) target:self title:@"防止同时抢多个红包" on:[WBRedEnvelopConfig sharedConfig].serialReceive];
}

- (MMTableViewCellInfo *)createBlackListCell {

    if ([WBRedEnvelopConfig sharedConfig].blackList.count == 0) {
        return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(showBlackList) target:self title:@"这些群不抢" rightValue:@"已关闭" accessoryType:1];
    } else {
        NSString *blackListCountStr = [NSString stringWithFormat:@"已选 %lu 个群", (unsigned long)[WBRedEnvelopConfig sharedConfig].blackList.count];
        return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(showBlackList) target:self title:@"这些群不抢" rightValue:blackListCountStr accessoryType:1];
    }
    
}

- (MMTableViewSectionInfo *)createComingSoonCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"更多功能开发中" rightValue:@"敬请期待..."];
}
            
- (void)settingReceiveByQueue:(UISwitch *)queueSwitch {
    [WBRedEnvelopConfig sharedConfig].serialReceive = queueSwitch.on;
}

- (void)showBlackList {
    WBMultiSelectGroupsViewController *contactsViewController = [[WBMultiSelectGroupsViewController alloc] initWithBlackList:[WBRedEnvelopConfig sharedConfig].blackList];
    contactsViewController.delegate = self;

    MMUINavigationController *navigationController = [[objc_getClass("MMUINavigationController") alloc] initWithRootViewController:contactsViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - About
- (void)addAboutSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoDefaut];
    
    [sectionInfo addCell:[self createIntroductionCell]];
    [sectionInfo addCell:[self createGithubCell]];
    [sectionInfo addCell:[self createBlogCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewCellInfo *)createIntroductionCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(showIntroduction) target:self title:@"使用说明" accessoryType:1];
}

- (MMTableViewCellInfo *)createGithubCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(showGithub) target:self title:@"我的 Github" accessoryType:1];
}

- (MMTableViewCellInfo *)createBlogCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(showBlog) target:self title:@"我的博客" accessoryType:1];
}

- (void)showIntroduction {
    NSURL *introductionUrl = [NSURL URLWithString:@"https://github.com/buginux/WeChatRedEnvelop/blob/RedEnvelopPro/Introduction/Introduction.md"];
    MMWebViewController *webViewController = [[objc_getClass("MMWebViewController") alloc] initWithURL:introductionUrl presentModal:NO extraInfo:nil];
    [self.navigationController PushViewController:webViewController animated:YES];
}

- (void)showGithub {
    NSURL *gitHubUrl = [NSURL URLWithString:@"https://www.github.com/buginux"];
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
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoDefaut];
    
    [sectionInfo addCell:[self createWeChatPayingCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewCellInfo *)createWeChatPayingCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(payingToAuthor) target:self title:@"微信打赏" rightValue:@"支持作者开发" accessoryType:1];
}

- (void)payingToAuthor {
    [self startLoadingNonBlock];
    ScanQRCodeLogicController *scanQRCodeLogic = [[objc_getClass("ScanQRCodeLogicController") alloc] initWithViewController:self CodeType:3];
    scanQRCodeLogic.fromScene = 2;
    
    NewQRCodeScanner *qrCodeScanner = [[objc_getClass("NewQRCodeScanner") alloc] initWithDelegate:scanQRCodeLogic CodeType:3];
    [qrCodeScanner notifyResult:@"https://wx.tenpay.com/f2f?t=AQAAABxXiDaVyoYdR5F1zBNM5jI%3D" type:@"QR_CODE" version:6];
}

#pragma mark - MultiSelectContactsViewControllerDelegate

- (void)onMultiSelectContactReturn:(NSArray *)arg1 {
    NSString *message = [NSString stringWithFormat:@"%s -- %@", __func__, arg1];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    NSLog(@"vvvvvvvv -- %@", message);
}

- (void)onMultiSelectContactCancelForSns {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"%s", __func__] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onMultiSelectContactReturnForSns:(NSArray *)arg1 {
    NSString *message = [NSString stringWithFormat:@"%s -- %@", __func__, arg1];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    NSLog(@"vvvvvvvv -- %@", message);
    
}

#pragma mark - MultiSelectGroupsViewControllerDelegate
- (void)onMultiSelectGroupCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)onMultiSelectGroupReturn:(NSArray *)arg1 {
    [WBRedEnvelopConfig sharedConfig].blackList = arg1;
    
    [self reloadTableData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
