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
static NSString * const kSerialReceiveKey = @"WBSerialReceiveKey";
static NSString * const kBlackListKey = @"WBBlackListKey";

@interface WBRedEnvelopConfig () {
    NSArray *_blackList;
}

@end

@implementation WBRedEnvelopConfig

@synthesize blackList = _blackList;

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

- (NSArray<CContact *> *)blackList {
    if (!_blackList) {
        [NSArray arrayWithContentsOfFile:[self blackListFilePath]];
    }
    return _blackList;
}

- (void)setBlackList:(NSArray *)blackList {
    _blackList = blackList;
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *blackListFilePath = [documentPath stringByAppendingPathComponent:@"blackList.plist"];
    BOOL success = [blackList writeToFile:blackListFilePath atomically:YES];
    if (!success) {
        NSLog(@"vvvvvvvv --- Save blackList failed");
    }
//    [[NSUserDefaults standardUserDefaults] setObject:blackList forKey:kBlackListKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)blackListFilePath {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [documentPath stringByAppendingString:@"blackList.plist"];
}

@end
