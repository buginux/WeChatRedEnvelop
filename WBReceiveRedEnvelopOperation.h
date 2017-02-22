//
//  WBReceiveRedEnvelopOperation.h
//  WeChatRedEnvelop
//
//  Created by wordbeyondyoung on 17/2/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WeChatRedEnvelopParam;
@interface WBReceiveRedEnvelopOperation : NSOperation

- (instancetype)initWithRedEnvelopParam:(WeChatRedEnvelopParam *)param delay:(unsigned int)delaySeconds;

@end
