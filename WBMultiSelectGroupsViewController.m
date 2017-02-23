//
//  WBMultiSelectGroupsViewController.m
//  WeChatRedEnvelop
//
//  Created by 杨志超 on 2017/2/24.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import "WBMultiSelectGroupsViewController.h"
#import "WeChatRedEnvelop.h"
#import <objc/objc-runtime.h>

@interface WBMultiSelectGroupsViewController ()

@property (strong, nonatomic) ContactSelectView *selectView;

@end

@implementation WBMultiSelectGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectView = [[objc_getClass("ContactSelectView") alloc] initWithFrame:[UIScreen mainScreen].bounds delegate:self];
    [self.selectView initData:4];
    [self.selectView initView];
    
    [self.view addSubview:self.selectView];
}

- (UIViewController *)getViewController {
    return nil;
}

@end
