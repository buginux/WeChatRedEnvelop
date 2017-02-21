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

@interface WBSettingViewController ()

@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;

@end

@implementation WBSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        Class tableViewInfoClass = NSClassFromString(@"MMTableViewInfo");
        
        _tableViewInfo = [[tableViewInfoClass alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadTableData];
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [self.view addSubview:tableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)reloadTableData {
    [self.tableViewInfo clearAllSection];
    
    Class SectionInfoClass = NSClassFromString(@"MMTableViewSectionInfo");
    Class CellInfoClass = NSClassFromString(@"MMTableViewCellInfo");
    
    MMTableViewSectionInfo *sectionInfo = [SectionInfoClass sectionInfoDefaut];
    
     BOOL redEnvelopSwitchOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"XGWeChatRedEnvelopSwitchKey"];
    NSInteger delaySeconds = [WBRedEnvelopConfig sharedConfig].delaySeconds;
    
     MMTableViewCellInfo *cellInfo = [CellInfoClass switchCellForSel:@selector(switchRedEnvelop:) target:self title:@"自动抢红包" on:redEnvelopSwitchOn];
     NSString *delaySecondsString = delaySeconds == 0 ? @"不延迟" : [NSString stringWithFormat:@"%ld 秒", (long)delaySeconds];
     NSInteger accessoryType = 1;
    
     MMTableViewCellInfo *delayCellInfo;
     if (!redEnvelopSwitchOn) {
     	delayCellInfo = [CellInfoClass normalCellForTitle:@"延迟抢红包" rightValue:@"自动抢红包已关闭"];
     } else {
     	delayCellInfo = [CellInfoClass normalCellForSel:@selector(settingDelay) target:self title:@"延迟抢红包" rightValue:delaySecondsString accessoryType:accessoryType];
     }
    
     MMTableViewCellInfo *payingCellInfo = [CellInfoClass normalCellForSel:@selector(payingToAuthor) target:self title:@"打赏" rightValue:@"支持作者开发" accessoryType:1];
    
     [sectionInfo addCell:cellInfo];
     [sectionInfo addCell:delayCellInfo];
     [sectionInfo addCell:payingCellInfo];
    
     [self.tableViewInfo insertSection:sectionInfo At:0];
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}

- (void)switchRedEnvelop:(UISwitch *)envelopSwitch {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:envelopSwitch.on forKey:@"XGWeChatRedEnvelopSwitchKey"];
    
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

- (void)payingToAuthor {
    Class ScanQRCodeLogicControllerClass = NSClassFromString(@"ScanQRCodeLogicController");
    Class NewQRCodeScannerClass = NSClassFromString(@"NewQRCodeScanner");
    
    ScanQRCodeLogicController *scanQRCodeLogic = [[ScanQRCodeLogicControllerClass alloc] initWithViewController:self CodeType:3];
    scanQRCodeLogic.fromScene = 2;
    
    NewQRCodeScanner *qrCodeScanner = [[NewQRCodeScannerClass alloc] initWithDelegate:scanQRCodeLogic CodeType:3];
    [qrCodeScanner notifyResult:@"https://wx.tenpay.com/f2f?t=AQAAABxXiDaVyoYdR5F1zBNM5jI%3D" type:@"QR_CODE" version:6];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *delaySecondsString = [alertView textFieldAtIndex:0].text;
        NSInteger delaySeconds = [delaySecondsString integerValue];
        
        [WBRedEnvelopConfig sharedConfig].delaySeconds = delaySeconds;
        
        [self reloadTableData];
    }
}

@end
