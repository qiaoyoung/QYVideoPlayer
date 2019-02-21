//
//  QYPlayerView.h
//  QYVideoPlayer
//
//  Created by Joeyoung on 2019/1/18.
//  Copyright © 2019 Joeyoung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "QYPlayerControlView.h"

NS_ASSUME_NONNULL_BEGIN

@interface QYPlayerView : UIView

/** 操作视频视图 */
@property (nonatomic, strong) QYPlayerControlView *controlView;
/** 当前设备的方向属性 */
@property (nonatomic, assign) UIInterfaceOrientation lastOrientation;
/** 播放标题 */
@property (nonatomic, copy) NSString *title;
/** 清晰度 */
@property (nonatomic, copy) NSString *definition;
/** 是否锁屏 */
@property (nonatomic, assign) BOOL isLockScreen;

/**
 播放视频

 @param string 视频地址
 */
- (void)qy_loadVideo:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
