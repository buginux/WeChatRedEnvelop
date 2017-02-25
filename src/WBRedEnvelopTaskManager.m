//
//  WBRedEnvelopTaskManager.m
//  WeChatRedEnvelop
//
//  Created by wordbeyondyoung on 17/2/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import "WBRedEnvelopTaskManager.h"
#import "WBReceiveRedEnvelopOperation.h"

@interface WBRedEnvelopTaskManager ()

@property (strong, nonatomic) NSOperationQueue *normalTaskQueue;
@property (strong, nonatomic) NSOperationQueue *serialTaskQueue;

@end

@implementation WBRedEnvelopTaskManager

+ (instancetype)sharedManager {
    static WBRedEnvelopTaskManager *taskManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        taskManager = [WBRedEnvelopTaskManager new];
    });
    return taskManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _serialTaskQueue = [[NSOperationQueue alloc] init];
        _serialTaskQueue.maxConcurrentOperationCount = 1;
        
        _normalTaskQueue = [[NSOperationQueue alloc] init];
        _normalTaskQueue.maxConcurrentOperationCount = 5;
    }
    return self;
}

- (void)addNormalTask:(WBReceiveRedEnvelopOperation *)task {
    [self.normalTaskQueue addOperation:task];
}

- (void)addSerialTask:(WBReceiveRedEnvelopOperation *)task {
    [self.serialTaskQueue addOperation:task];
}

- (BOOL)serialQueueIsEmpty {
    return [self.serialTaskQueue operations].count == 0;
}

@end
