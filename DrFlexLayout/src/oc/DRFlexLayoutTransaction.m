//
//  DRFlexLayoutTransaction.m
//  drbox
//
//  Created by dr.box on 2020/8/1.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRFlexLayoutTransaction.h"
#import <os/lock.h>


static os_unfair_lock _dr_flex_lock = OS_UNFAIR_LOCK_INIT;

static inline NSMutableArray * messageQueue(){
    static NSMutableArray *messageQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        messageQueue = [NSMutableArray array];
    });
    return messageQueue;
}

/// 消息队列
static dispatch_queue_t transactionQueue() {
  static dispatch_queue_t transactionQueue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      dispatch_qos_class_t qosClass = QOS_CLASS_DEFAULT;
      dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, qosClass, 0);
      transactionQueue = dispatch_queue_create("com.drbox.layout.transaction", attr);
  });
  return transactionQueue;
}

/// 入队列
static inline void pushQueue(dispatch_block_t block) {
    os_unfair_lock_lock(&_dr_flex_lock);
    [messageQueue() addObject:block];
    CFRunLoopWakeUp(CFRunLoopGetMain());// 唤醒main runloop
    os_unfair_lock_unlock(&_dr_flex_lock);
}
/// 执行队列
static inline void processQueue(){
    os_unfair_lock_lock(&_dr_flex_lock);
    for (dispatch_block_t block in messageQueue()) {
        block();
    }
    [messageQueue() removeAllObjects];
    os_unfair_lock_unlock(&_dr_flex_lock);
}

/// runloop状态回调
static void DRRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    processQueue();
}

@implementation DRFlexLayoutTransaction

+ (void)load{
    // 注册runloop状态监听
    CFRunLoopObserverRef observer;
    CFRunLoopRef runLoop = CFRunLoopGetMain();
    CFOptionFlags activities = (kCFRunLoopBeforeWaiting | kCFRunLoopExit);
    observer = CFRunLoopObserverCreate(NULL,
                                       activities,
                                       true,        // repeat
                                       0xFFFFFF,   // after CATransaction(2000000)
                                       DRRunLoopObserverCallBack,
                                       NULL);
    if (observer) {
      CFRunLoopAddObserver(runLoop, observer, kCFRunLoopCommonModes);
      CFRelease(observer);
    }
}

+ (void)addTransaction:(dispatch_block_t)block
              complete:(dispatch_block_t)complete{
    dispatch_async(transactionQueue(), ^{
        block();
        pushQueue(complete);
    });
}

@end
