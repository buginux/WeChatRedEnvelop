//
//  WBRedEnvelopParamQueue.h
//  WeChatRedEnvelop
//
//  Created by 杨志超 on 2017/2/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WeChatRedEnvelopParam;
@interface WBRedEnvelopParamQueue : NSObject

+ (instancetype)sharedQueue;

- (void)enqueue:(WeChatRedEnvelopParam *)param;
- (WeChatRedEnvelopParam *)dequeue;
- (WeChatRedEnvelopParam *)peek;
- (BOOL)isEmpty;

@end
