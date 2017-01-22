//
//  WeChatRedEnvelopParam.m
//  WeChatRedEnvelop
//
//  Created by 杨志超 on 2017/1/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import "WeChatRedEnvelopParam.h"

@implementation WeChatRedEnvelopParam

+ (instancetype)sharedInstance {
    static WeChatRedEnvelopParam *sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WeChatRedEnvelopParam alloc] init];
    });
    
    return sharedInstance;
}

- (NSDictionary *)toParams {
    return @{
             @"msgType": self.msgType,
             @"sendId": self.sendId,
             @"channelId": self.channelId,
             @"nickName": self.nickName,
             @"headImg": self.headImg,
             @"nativeUrl": self.nativeUrl,
             @"sessionUserName": self.sessionUserName,
             @"timingIdentifier": self.timingIdentifier
             };
}

@end
