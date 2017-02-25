//
//  WBRedEnvelopParamQueue.m
//  WeChatRedEnvelop
//
//  Created by 杨志超 on 2017/2/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import "WBRedEnvelopParamQueue.h"
#import "WeChatRedEnvelopParam.h"

@interface WBRedEnvelopParamQueue ()

@property (strong, nonatomic) NSMutableArray *queue;

@end

@implementation WBRedEnvelopParamQueue

+ (instancetype)sharedQueue {
    static WBRedEnvelopParamQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[WBRedEnvelopParamQueue alloc] init];
    });
    return queue;
}

- (instancetype)init {
    if (self = [super init]) {
        _queue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)enqueue:(WeChatRedEnvelopParam *)param {
    [self.queue addObject:param];
}

- (WeChatRedEnvelopParam *)dequeue {
    if (self.queue.count == 0 && !self.queue.firstObject) {
        return nil;
    }
    
    WeChatRedEnvelopParam *first = self.queue.firstObject;
    
    [self.queue removeObjectAtIndex:0];
    
    return first;
}

- (WeChatRedEnvelopParam *)peek {
    if (self.queue.count == 0) {
        return nil;
    }
    
    return self.queue.firstObject;
}

- (BOOL)isEmpty {
    return self.queue.count == 0;
}



@end
