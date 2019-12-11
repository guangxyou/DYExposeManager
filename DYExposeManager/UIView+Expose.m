//
//  UIView+Expose.m
//  DYExposeManagerDemo
//
//  Created by ygx on 2019/12/11.
//  Copyright © 2019 ygx. All rights reserved.
//

#import "UIView+Expose.h"
#import "DYExposeManager.h"
#import <objc/runtime.h>

@implementation UIView (Expose)

+ (void)load {
    // 替换willMoveToWindow方法
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(willMoveToWindow:);
        SEL swizzledSelector = @selector(dy_willMoveToWindow:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)dy_willMoveToWindow:(UIWindow *)window {
    [self dy_willMoveToWindow:window];
    if (self.dy_ShouldDetectExpose && self.dy_DidExposedBlock) {
        [[DYExposeManager sharedInstance] addExposeObserveOfView:self];
    }
}

#pragma mark - Associated Object

- (BOOL)dy_ShouldDetectExpose {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void (^)(void))dy_DidExposedBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDy_ShouldDetectExpose:(BOOL)dy_ShouldDetectExpose {
    objc_setAssociatedObject(self, @selector(dy_ShouldDetectExpose), @(dy_ShouldDetectExpose), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setDy_DidExposedBlock:(void (^)(void))dy_DidExposedBlock {
    objc_setAssociatedObject(self, @selector(dy_DidExposedBlock), dy_DidExposedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - Visible

- (BOOL)isVisible {
    if (self.hidden || self.alpha <= 0.01 || !self.superview) {
        return NO;
    }
    return [self isVisible:self inView:self.superview];
}

- (BOOL)isVisible:(UIView *)subView inView:(UIView *)view{
    if (subView == view) {
        return YES;
    }
    if ([view isKindOfClass:NSClassFromString(@"UITableViewWrapperView")]) {
        view = view.superview;
    }
    CGRect rect = [view convertRect:subView.frame fromView:view];
    if (CGRectIntersectsRect(rect, view.bounds)) {
        return [self isVisible:view inView:view.superview];
    }
    return NO;
}



@end
