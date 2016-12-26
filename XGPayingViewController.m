//
//  XGPayingViewController.m
//  DownloadTable
//
//  Created by 杨志超 on 2016/12/24.
//  Copyright © 2016年 swiftyper. All rights reserved.
//

#import "XGPayingViewController.h"
#import "WeChatRedEnvelop.h"
#import <objc/objc-runtime.h>

@interface XGPayingViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *scanButton;
@property (nonatomic, strong) ScanQRCodeLogicController *scanQRCodeLogic;

@end

@implementation XGPayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ScanQRCodeLogicController *scanQRCodeLogic = [[objc_getClass("ScanQRCodeLogicController") alloc] initWithViewController:self CodeType:3];
    scanQRCodeLogic.fromScene = 2;
    self.scanQRCodeLogic = scanQRCodeLogic;
    
    NSString *payingImagePath = @"/Library/Application Support/WeChat/WechatPaying.png";
    UIImage *payingImage = [UIImage imageWithContentsOfFile:payingImagePath];    
    if (!payingImage) {
        payingImagePath = [[NSBundle mainBundle] pathForResource:@"WechatPaying" ofType:@"png"];
        payingImage = [UIImage imageWithContentsOfFile:payingImagePath];
    }
    
    [scanQRCodeLogic tryScanOnePicture:payingImage];
    
    self.view.backgroundColor = [UIColor blackColor];
    
//    UIImage *payingImage = [UIImage imageNamed:@"WechatPaying"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:payingImage];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:imageView];
    imageView.userInteractionEnabled = YES;
    self.imageView = imageView;
    
    UIButton *scaningButton = [UIButton buttonWithType:UIButtonTypeSystem];
    scaningButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scaningButton];
    self.scanButton = scaningButton;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(imageView, scaningButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:views]];
    [imageView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    [scaningButton setTitle:@"识别图中二维码" forState:UIControlStateNormal];
    [scaningButton setBackgroundColor:[UIColor whiteColor]];
    [scaningButton addTarget:self action:@selector(scan:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView]-(16)-[scaningButton]" options:NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing metrics:0 views:views]];
    [scaningButton addConstraint:[NSLayoutConstraint constraintWithItem:scaningButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:48.0]];
}

- (void)scan:(UIButton *)button {
    NSString *payingImagePath = @"/Library/Application Support/WeChat/WechatPaying.png";
    UIImage *payingImage = [UIImage imageWithContentsOfFile:payingImagePath];    
    if (!payingImage) {
        payingImagePath = [[NSBundle mainBundle] pathForResource:@"WechatPaying" ofType:@"png"];
        payingImage = [UIImage imageWithContentsOfFile:payingImagePath];
    }

    [self.scanQRCodeLogic doScanQRCode:payingImage];
    
    [self.scanQRCodeLogic showScanResult];
}

@end
