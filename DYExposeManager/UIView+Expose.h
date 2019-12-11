//
//  UIView+Expose.h
//  DYExposeManagerDemo
//
//  Created by ygx on 2019/12/11.
//  Copyright © 2019 ygx. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Expose)

@property (nonatomic, assign) BOOL dy_ShouldDetectExpose;
@property (nonatomic, copy) void (^dy_DidExposedBlock)(void);  // called after every expose

- (BOOL)isVisible;

@end

NS_ASSUME_NONNULL_END
