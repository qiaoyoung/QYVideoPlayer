//
//  QYPlayerControlView.h
//  QYVideoPlayer
//
//  Created by Joeyoung on 2019/1/19.
//  Copyright © 2019 Joeyoung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYPlayerProgress.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QYPlayerControlViewEvent) {
    QYPlayerControlViewEvent_Back,               // 返回
    QYPlayerControlViewEvent_Fullscreen,         // 全屏
    QYPlayerControlViewEvent_Smallscreen,        // 竖屏
    QYPlayerControlViewEvent_lock,               // 锁屏
    QYPlayerControlViewEvent_unlock,             // 解锁屏
    QYPlayerControlViewEvent_Play,               // 播放
    QYPlayerControlViewEvent_Pause,              // 暂停
    QYPlayerControlViewEvent_Next,               // 下一集
    QYPlayerControlViewEvent_Seek,               // 拖动进度
    QYPlayerControlViewEvent_Definition,         // 切换清晰度
    QYPlayerControlViewEvent_Share,              // 分享
    QYPlayerControlViewEvent_Speedup,            // 加速播放
    QYPlayerControlViewEvent_SpeedDown,          // 停止加速播放
    QYPlayerControlViewEvent_Cast,               // 投屏
    QYPlayerControlViewEvent_ChangeCastDevice,   // 切换投屏设备
    QYPlayerControlViewEvent_StopCast,           // 停止投屏
};

@protocol QYPlayerControlViewDelegate <NSObject>

- (void)qy_PlayerControlViewButtonClickWithEvent:(QYPlayerControlViewEvent)event;

@end

@interface QYPlayerControlView : UIView

/** delegate */
@property(nonatomic, weak) id<QYPlayerControlViewDelegate> delegate;

/** 视频标题 */
@property (nonatomic, strong) UILabel *titleLab;
/** 视频清晰度 */
@property (nonatomic, strong) UIButton *definitionBtn;
/** 播放按钮 */
@property (nonatomic, strong) UIButton *playBtn;
/** 锁屏按钮 */
@property (nonatomic, strong) UIButton *lockBtn;
/** 当前时间 */
@property (nonatomic, strong) UILabel *currentTimeLab;
/** 总时间 */
@property (nonatomic, strong) UILabel *totalTimeLab;
/** 播放进度条 */
@property (nonatomic, strong) QYPlayerProgress *progressBar;
/** 是否全屏 YES:全屏*/
@property (nonatomic, assign) BOOL isFullscreen;
/** 是否显示控制视图 */
@property (nonatomic, assign) BOOL isShowControlView;
 
/**
 先显示再隐藏控制视图
 @param animated 是否动画
 */
- (void)qy_showThenHideControlViewWithAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
