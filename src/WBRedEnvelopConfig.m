//
//  WBRedEnvelopConfig.m
//  WeChatRedEnvelop
//
//  Created by 杨志超 on 2017/2/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import "WBRedEnvelopConfig.h"
#import "WeChatRedEnvelop.h"

static NSString * const kDelaySecondsKey = @"XGDelaySecondsKey";
static NSString * const kAutoReceiveRedEnvelopKey = @"XGWeChatRedEnvelopSwitchKey";
static NSString * const kReceiveSelfRedEnvelopKey = @"WBReceiveSelfRedEnvelopKey";
static NSString * const kSerialReceiveKey = @"WBSerialReceiveKey";
static NSString * const kBlackListKey = @"WBBlackListKey";
static NSString * const kRevokeEnablekey = @"WBRevokeEnable";

@interface WBRedEnvelopConfig ()

@end

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
        _blackList = [[NSUserDefaults standardUserDefaults] objectForKey:kBlackListKey];
        _receiveSelfRedEnvelop = [[NSUserDefaults standardUserDefaults] boolForKey:kReceiveSelfRedEnvelopKey];
        _revokeEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kRevokeEnablekey];
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

- (void)setReceiveSelfRedEnvelop:(BOOL)receiveSelfRedEnvelop {
    _receiveSelfRedEnvelop = receiveSelfRedEnvelop;
    
    [[NSUserDefaults standardUserDefaults] setBool:receiveSelfRedEnvelop forKey:kReceiveSelfRedEnvelopKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSerialReceive:(BOOL)serialReceive {
    _serialReceive = serialReceive;
    
    [[NSUserDefaults standardUserDefaults] setBool:serialReceive forKey:kSerialReceiveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setBlackList:(NSArray *)blackList {
    _blackList = blackList;
    
    [[NSUserDefaults standardUserDefaults] setObject:blackList forKey:kBlackListKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setRevokeEnable:(BOOL)revokeEnable {
    _revokeEnable = revokeEnable;
    
    [[NSUserDefaults standardUserDefaults] setBool:revokeEnable forKey:kRevokeEnablekey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
