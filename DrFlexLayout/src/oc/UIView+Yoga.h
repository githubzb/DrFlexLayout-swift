/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>
#import "YGLayout.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^YGLayoutFinishBlock)(__kindof UIView * _Nullable view);

@interface UIView (Yoga)

/**
 The YGLayout that is attached to this view. It is lazily created.
 */
@property(nonatomic, readonly, strong) YGLayout* yoga;

/**
 Indicates whether or not Yoga is enabled
 */
@property (nonatomic, readonly, assign) BOOL isYogaEnabled;

/**
 The layout finish callback list for current view.
 */
@property(nonatomic, readonly, strong, nullable) NSArray<YGLayoutFinishBlock> *layoutFinishBlockList;

/**
 The layout finish callback map for current view.
 */
@property(nonatomic, readonly, strong, nullable) NSDictionary<NSString *, YGLayoutFinishBlock> *layoutFinishBlockMap;

/**
 Add layout finish callback for current view.
 */
- (void)addLayoutFinishBlock:(YGLayoutFinishBlock)block;

/**
 Add layout finish callback for current view.
 */
- (void)addLayoutFinishBlock:(YGLayoutFinishBlock)block forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
