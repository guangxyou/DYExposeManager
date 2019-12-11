//
//  DYExposeManager.m
//  DYExposeManagerDemo
//
//  Created by ygx on 2019/12/11.
//  Copyright © 2019 ygx. All rights reserved.
//

#import "DYExposeManager.h"
#import "UIView+Expose.h"

@interface DYExposeManager () {
    CFRunLoopObserverRef observer;
}

@property (nonatomic, strong) NSHashTable <UIView *> *observedViews;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSNumber *> *lastRunloopExposeStatus;

@end

@implementation DYExposeManager

+ (instancetype)sharedInstance {
    static DYExposeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DYExposeManager alloc] init];
        [manager customInit];
    });
    return manager;
}

- (void)customInit {
    self.observedViews = [NSHashTable weakObjectsHashTable];
    self.lastRunloopExposeStatus = [NSMutableDictionary dictionary];
    
    [self addRunLoopObserver];
    
    // App 切到前台继续监听Runloop状态
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self addRunLoopObserver];
    }];
    // App 切到后台不再监听Runloop状态
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self removeRunloopObserver];
                                                  }];
}

- (void)addRunLoopObserver {
    if (observer != NULL) {
        [self removeRunloopObserver];
    }
    // 监控线程对应的Runloop即将休眠
    __weak typeof(self) weakSelf = self;
    observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        if (activity == kCFRunLoopBeforeWaiting) {
            [weakSelf refreshObservedViewsExposeStatus];
        }
    });
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
}

- (void)removeRunloopObserver {
    if (observer != NULL) {
        CFRunLoopObserverInvalidate(observer);
        CFRelease(observer);
        observer = NULL;
    }
}

- (void)addExposeObserveOfView:(UIView *)view {
    if (!view || ![view isKindOfClass:[UIView class]] || !view.dy_ShouldDetectExpose || !view.dy_DidExposedBlock) {
        return ;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateView:view isExposed:NO];
        [self.observedViews addObject:view];
    });
}

- (void)removeExposeObserveOfView:(UIView *)view {
    if (!view || ![view isKindOfClass:[UIView class]]) {
        return ;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeViewExposeStatus:view];
        [self.observedViews removeObject:view];
    });
}

- (void)refreshObservedViewsExposeStatus {
    for (UIView *view in self.observedViews.allObjects) {
        if ([view isVisible]) {
            if (view.dy_ShouldDetectExpose && view.dy_DidExposedBlock && ![self isExposedLastRunloop:view]) {
                view.dy_DidExposedBlock();
            }
            [self updateView:view isExposed:YES];
        } else {
            [self updateView:view isExposed:NO];
        }
    }
}

- (BOOL)isExposedLastRunloop:(UIView *)view {
    if (!view || ![view isKindOfClass:[UIView class]]) {
        return NO;
    }
    NSString *key = [NSString stringWithFormat:@"%p",view];
    return [[self.lastRunloopExposeStatus valueForKey:key] boolValue];
}

- (void)updateView:(UIView *)view isExposed:(BOOL)isExposed {
    if (!view || ![view isKindOfClass:[UIView class]]) {
        return ;
    }
    NSString *key = [NSString stringWithFormat:@"%p",view];
    [self.lastRunloopExposeStatus setValue:@(isExposed) forKey:key];
}

- (void)removeViewExposeStatus:(UIView *)view {
    if (!view || ![view isKindOfClass:[UIView class]]) {
        return ;
    }
    NSString *key = [NSString stringWithFormat:@"%p",view];
    [self.lastRunloopExposeStatus removeObjectForKey:key];
}



@end
