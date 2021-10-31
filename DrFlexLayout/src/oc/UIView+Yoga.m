/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <objc/runtime.h>
#import "UIView+Yoga.h"
#import "YGLayout+Private.h"

static const void* kYGYogaAssociatedKey = &kYGYogaAssociatedKey;
static const void* kYGLayoutFinishCallbackListAssociatedKey = &kYGLayoutFinishCallbackListAssociatedKey;
static const void* kYGLayoutFinishCallbackMapAssociatedKey = &kYGLayoutFinishCallbackMapAssociatedKey;

@implementation UIView (YogaKit)

- (YGLayout*)yoga {
  YGLayout* yoga = objc_getAssociatedObject(self, kYGYogaAssociatedKey);
  if (!yoga) {
    yoga = [[YGLayout alloc] initWithView:self];
    objc_setAssociatedObject(
        self, kYGYogaAssociatedKey, yoga, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }

  return yoga;
}

- (BOOL)isYogaEnabled
{
  return objc_getAssociatedObject(self, kYGYogaAssociatedKey) != nil;
}

- (NSArray<YGLayoutFinishBlock> *)layoutFinishBlockList{
    return objc_getAssociatedObject(self, kYGLayoutFinishCallbackListAssociatedKey);
}

- (NSDictionary<NSString *,void (^)(__kindof UIView * _Nullable)> *)layoutFinishBlockMap{
    return objc_getAssociatedObject(self, kYGLayoutFinishCallbackMapAssociatedKey);
}

- (void)addLayoutFinishBlock:(YGLayoutFinishBlock)block{
    NSMutableArray<YGLayoutFinishBlock> *list = objc_getAssociatedObject(self, kYGLayoutFinishCallbackListAssociatedKey);
    if (!list) {
        list = [@[] mutableCopy];
        objc_setAssociatedObject(self,
                                 kYGLayoutFinishCallbackListAssociatedKey,
                                 list,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [list addObject:block];
}

- (void)addLayoutFinishBlock:(YGLayoutFinishBlock)block forKey:(NSString *)key{
    NSMutableDictionary *map = objc_getAssociatedObject(self, kYGLayoutFinishCallbackMapAssociatedKey);
    if (!map) {
        map = [@{} mutableCopy];
        objc_setAssociatedObject(self,
                                 kYGLayoutFinishCallbackMapAssociatedKey,
                                 map,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    map[key] = block;
}

@end
