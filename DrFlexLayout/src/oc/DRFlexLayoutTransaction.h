//
//  DRFlexLayoutTransaction.h
//  drbox
//
//  Created by dr.box on 2020/8/1.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRFlexLayoutTransaction : NSObject

/**
 添加布局事务
 
 @param block 事务block
 @param complete 事务执行完毕
 */
+ (void)addTransaction:(dispatch_block_t)block
              complete:(dispatch_block_t)complete;

@end

NS_ASSUME_NONNULL_END
