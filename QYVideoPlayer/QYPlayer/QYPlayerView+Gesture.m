//
//  QYPlayerView+Gesture.m
//  QYVideoPlayer
//
//  Created by Joeyoung on 2019/1/31.
//  Copyright © 2019 Joeyoung. All rights reserved.
//

#import "QYPlayerView+Gesture.h"

@implementation QYPlayerView (Gesture)

- (void)qy_setupGesture {
    // 添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAvction:)];
    [self addGestureRecognizer:tap];
}

#pragma mark - TapGesture (控制视图的显示与隐藏)
- (void)tapGestureAvction:(UITapGestureRecognizer *)tapGesture {
    // 先显示再隐藏控制视图
    [self.controlView qy_showThenHideControlViewWithAnimated:YES];
}

@end
