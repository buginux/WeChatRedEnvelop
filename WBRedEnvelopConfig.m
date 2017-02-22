//
//  WBRedEnvelopConfig.m
//  WeChatRedEnvelop
//
//  Created by 杨志超 on 2017/2/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import "WBRedEnvelopConfig.h"

static NSString * const kDelaySecondsKey = @"XGDelaySecondsKey";
static NSString * const kAutoReceiveRedEnvelopKey = @"XGWeChatRedEnvelopSwitchKey";
static NSString * const kSerialReceiveKey = @"WBSerialReceiveKey";

@implementation WBRedEnvelopConfig

+ (instancetype)sharedConfig {
    static WBRedEnvelopConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [WBRedEnvelopConfig new];
    });
    return config;
}

- (instancetype)init {
    if (self = [super init]) {
        _delaySeconds = [[NSUserDefaults standardUserDefaults] integerForKey:kDelaySecondsKey];
        _autoReceiveEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoReceiveRedEnvelopKey];
        _serialReceive = [[NSUserDefaults standardUserDefaults] boolForKey:kSerialReceiveKey];
    }
    return self;
}

- (void)setDelaySeconds:(NSInteger)delaySeconds {
    _delaySeconds = delaySeconds;
    
    [[NSUserDefaults standardUserDefaults] setInteger:delaySeconds forKey:kDelaySecondsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReceiveEnable:(BOOL)autoReceiveEnable {
    _autoReceiveEnable = autoReceiveEnable;
    
    [[NSUserDefaults standardUserDefaults] setBool:autoReceiveEnable forKey:kAutoReceiveRedEnvelopKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSerialReceive:(BOOL)serialReceive {
    _serialReceive = serialReceive;
    
    [[NSUserDefaults standardUserDefaults] setBool:serialReceive forKey:kSerialReceiveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
