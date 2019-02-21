//
//  QYPlayerView+Rotation.h
//  QYVideoPlayer
//
//  Created by Joeyoung on 2019/1/21.
//  Copyright © 2019 Joeyoung. All rights reserved.
//

#import "QYPlayerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface QYPlayerView (Rotation)

/**
 初始化旋转屏
 */
- (void)qy_setupRotation;

/**
 设置屏幕旋转方向

 @param orientation 屏幕方向
 @param animated 是否动画
 */
- (void)qy_setOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;


@end

NS_ASSUME_NONNULL_END
