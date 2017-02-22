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

@property (strong, nonatomic) NSOperationQueue *taskQueue;

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
        _taskQueue = [[NSOperationQueue alloc] init];
        _taskQueue.maxConcurrentOperationCount = 3;
    }
    return self;
}

- (void)addTask:(WBReceiveRedEnvelopOperation *)task {
    [self.taskQueue addOperation:task];
}

@end
