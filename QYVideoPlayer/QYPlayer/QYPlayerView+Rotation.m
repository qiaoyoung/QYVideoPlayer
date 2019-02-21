//
//  QYPlayerView+Rotation.m
//  QYVideoPlayer
//
//  Created by Joeyoung on 2019/1/21.
//  Copyright © 2019 Joeyoung. All rights reserved.
//

#import "QYPlayerView+Rotation.h"
#import "QYPlayerDefine.h"

@implementation QYPlayerView (Rotation)

- (void)qy_setupRotation {
    // 手动设置屏幕旋转方向
    [self qy_setOrientation:[self qy_getDeviceCurrentOrientation] animated:NO];
    // 添加通知
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(qy_orientationDidChangeNotif:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

// 设置屏幕旋转方向
- (void)qy_setOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    CGRect frame = CGRectZero;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth*9/16);
    } else {
        frame = CGRectMake(0, 0, kScreenWidth, kScreenHight);
    }
    [UIView animateWithDuration:animated ? 0.3f : 0 animations:^{
        self.frame = frame;
    }];
    // 当前设备的方向
    self.lastOrientation = orientation;
    // 调用强制设备旋转
    [self qy_forceDeviceSetOrientation:orientation];
}

// 手动点击横竖屏,强制设备旋转
- (void)qy_forceDeviceSetOrientation:(UIInterfaceOrientation)orientation {
    // 首先设置UIInterfaceOrientationUnknown欺骗系统，避免可能出现直接设置无效的情况
    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    NSNumber *orientationTarget = [NSNumber numberWithInt:orientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

// 获取当前屏幕方向
- (UIInterfaceOrientation)qy_getDeviceCurrentOrientation {
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    switch (statusBarOrientation) {
        case UIInterfaceOrientationPortrait: // home键在下
            return UIInterfaceOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown: // home键在上
            return UIInterfaceOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft: // home键在左
            return UIInterfaceOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight: // home键在右
            return UIInterfaceOrientationLandscapeRight;
            break;
        default:
            return self.lastOrientation;
            break;
    }
}

#pragma mark - UIDeviceOrientationDidChangeNotification
- (void)qy_orientationDidChangeNotif:(NSNotification *)notification {
    // 旋转屏幕时, 展示控制视图
    [self.controlView qy_showThenHideControlViewWithAnimated:YES];
    UIInterfaceOrientation orientation = [self qy_getDeviceCurrentOrientation];
    // 锁屏或者重复方向不作处理
    if (orientation == self.lastOrientation || self.isLockScreen) return;
    [self qy_setOrientation:orientation animated:YES];
    BOOL iSLandscape = UIInterfaceOrientationIsLandscape(orientation);
    self.controlView.isFullscreen = iSLandscape;
}

@end
