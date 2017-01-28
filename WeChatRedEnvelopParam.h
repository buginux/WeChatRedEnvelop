//
//  WeChatRedEnvelopParam.h
//  WeChatRedEnvelop
//
//  Created by 杨志超 on 2017/1/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeChatRedEnvelopParam : NSObject

+ (instancetype)sharedInstance;

- (NSDictionary *)toParams;

/** 开关控制 */
@property (assign, nonatomic) BOOL autoReceiveRedEnvelop; //:< 用于标记是否为自动抢红包
@property (assign, nonatomic) BOOL redEnvelopSwitchOn;
@property (assign, nonatomic) BOOL redEnvelopInChatRoomFromOther;
@property (assign, nonatomic) BOOL redEnvelopInChatRoomFromMe;

@property (strong, nonatomic) NSString *msgType;
@property (strong, nonatomic) NSString *sendId;
@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSString *nickName;
@property (strong, nonatomic) NSString *headImg;
@property (strong, nonatomic) NSString *nativeUrl;
@property (strong, nonatomic) NSString *sessionUserName;
@property (strong, nonatomic) NSString *timingIdentifier;

@end
