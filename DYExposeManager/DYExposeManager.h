//
//  DYExposeManager.h
//  DYExposeManagerDemo
//
//  Created by ygx on 2019/12/11.
//  Copyright © 2019 ygx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Expose.h"

NS_ASSUME_NONNULL_BEGIN

@interface DYExposeManager : NSObject

+ (instancetype)sharedInstance;

// 监测UIView曝光
- (void)addExposeObserveOfView:(UIView *)view;

 // 移除监测UIView曝光
- (void)removeExposeObserveOfView:(UIView *)view;


@end

NS_ASSUME_NONNULL_END
