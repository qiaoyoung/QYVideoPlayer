//
//  QYPlayerControlView.m
//  QYVideoPlayer
//
//  Created by Joeyoung on 2019/1/19.
//  Copyright © 2019 Joeyoung. All rights reserved.
//

#import "QYPlayerControlView.h"
#import "QYPlayerDefine.h"

// 动画时间
#define kAnimationInterval 0.3f
// 延时时间
#define kDelayInterval 3.f

// 按钮的tag基础值
static const NSInteger kButtonTagBaseValue = 10086;
// 默认顶部和底部操作视图高度
static const CGFloat kDefaultTopView_H = 34.f;
// iphoneX系列全屏边距
static const CGFloat kIphoneX_Margin = 50.f;

@interface QYPlayerControlView ()<QYPlayerProgressDelegate>

// 顶部导航层
/** 导航层 */
@property (nonatomic, strong) UIView *navView;
/** 返回按钮 */
@property (nonatomic, strong) UIButton *backBtn;
/** 投屏按钮 */
@property (nonatomic, strong) UIButton *castBtn;

// 底部操作视图
/** 底部视图 */
@property (nonatomic, strong) UIView *bottomView;
/** 下一首 */
@property (nonatomic, strong) UIButton *nextBtn;
/** 全屏按钮 */
@property (nonatomic, strong) UIButton *fullscreenBtn;

@end

@implementation QYPlayerControlView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isShowControlView = YES;
        [self createUIWithTopView];
        [self createUIWithBottomView];
        [self createUIWithMiddleView];
    }
    return self;
}

#pragma mark - UI
// 顶部导航层视图
- (void)createUIWithTopView {
    [self addSubview:self.navView];
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).mas_offset(kStatusbarHeight);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(kDefaultTopView_H);
    }];
    [self.navView addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.navView);
        make.width.equalTo(self.navView.mas_height);
    }];
    [self.navView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.navView);
        make.left.equalTo(self.backBtn.mas_right);
        make.width.mas_equalTo(self.navView.mas_width).multipliedBy(1/2.f);
    }];
    [self.navView addSubview:self.castBtn];
    [self.castBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.height.equalTo(self.navView);
        make.width.equalTo(self.navView.mas_height);
    }];
    [self.navView addSubview:self.definitionBtn];
    self.definitionBtn.hidden = YES;
    [self.definitionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.navView);
        make.right.equalTo(self.castBtn.mas_left).mas_offset(-5);
    }];
}
// 底部操作按钮视图
- (void)createUIWithBottomView {
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo(kDefaultTopView_H);
    }];
    [self.bottomView addSubview:self.playBtn];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.height.equalTo(self.bottomView);
        make.width.equalTo(self.bottomView.mas_height);
    }];
    [self.bottomView addSubview:self.nextBtn];
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playBtn.mas_right);
        make.top.height.equalTo(self.bottomView);
        make.width.equalTo(self.bottomView.mas_height);
    }];
    [self.bottomView addSubview:self.currentTimeLab];
    [self.currentTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nextBtn.mas_right);
        make.top.height.equalTo(self.bottomView);
        make.width.mas_equalTo(50.f);
    }];
    [self.bottomView addSubview:self.fullscreenBtn];
    [self.fullscreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView.mas_right);
        make.top.height.equalTo(self.bottomView);
        make.width.equalTo(self.bottomView.mas_height);
    }];
    [self.bottomView addSubview:self.totalTimeLab];
    [self.totalTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.fullscreenBtn.mas_left);
        make.top.height.equalTo(self.bottomView);
        make.width.mas_equalTo(50.f);
    }];
    [self.bottomView addSubview:self.progressBar];
    [self.progressBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLab.mas_right).mas_offset(5).priorityLow();
        make.right.equalTo(self.totalTimeLab.mas_left).mas_offset(-5);
        make.top.height.equalTo(self.bottomView);
    }];
}
// 中部操作按钮视图
- (void)createUIWithMiddleView {
    self.lockBtn.hidden = YES;
    [self addSubview:self.lockBtn];
    [self.lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.navView);
        make.centerY.equalTo(self);
        make.width.height.mas_equalTo(kDefaultTopView_H);
    }];
}
// 刷新UI
- (void)refreshControlViewUI {
    if (_isFullscreen) { // 全屏
        [self.navView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (kIsiPhoneXSeries) {
                make.top.equalTo(self).mas_offset(kIphoneX_Margin);
                make.left.equalTo(self).mas_offset(kIphoneX_Margin);
                make.right.equalTo(self).mas_offset(-kIphoneX_Margin);
            } else {
                make.top.equalTo(self).mas_offset(20);
            }
        }];
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (kIsiPhoneXSeries) {
                make.bottom.equalTo(self).mas_offset(-kIphoneX_Margin);
                make.left.equalTo(self).mas_offset(kIphoneX_Margin);
                make.right.equalTo(self).mas_offset(-kIphoneX_Margin);
            }
        }];
    } else {
        [self.navView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (kIsiPhoneXSeries) {
                make.top.equalTo(self).mas_offset(44);
            } else {
                make.top.equalTo(self).mas_offset(20);
            }
            make.left.right.equalTo(self);
        }];
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
        }];
    }
    // 显示/隐藏 锁屏按钮
    self.lockBtn.hidden = !_isFullscreen;
}

#pragma mark - QYPlayerProgressDelegate
- (void)qy_playProgressValueChanged {
    UIButton *button = [UIButton new];
    button.tag = kButtonTagBaseValue + QYPlayerControlViewEvent_Seek;
    [self buttonOnClick:button];
}

#pragma mark - Event
- (void)buttonOnClick:(UIButton *)button {
    button.selected = !button.selected;
    QYPlayerControlViewEvent event = button.tag - kButtonTagBaseValue;
    // 播放 -> 暂停
    if (button == _playBtn) {
        if (_playBtn.selected) event = QYPlayerControlViewEvent_Play;
        if (!_playBtn.selected) event = QYPlayerControlViewEvent_Pause;
    }
    // 锁屏 -> 解锁屏
    if (button == _lockBtn) {
        if (_lockBtn.selected) event = QYPlayerControlViewEvent_lock;
        if (!_lockBtn.selected) event = QYPlayerControlViewEvent_unlock;
     }
    // 全屏模式 -> 小屏
    if (_isFullscreen && (event == QYPlayerControlViewEvent_Fullscreen || event == QYPlayerControlViewEvent_Back)) {
        event = QYPlayerControlViewEvent_Smallscreen;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(qy_PlayerControlViewButtonClickWithEvent:)]) {
        [_delegate qy_PlayerControlViewButtonClickWithEvent:event];
    }
    // 操作完, 延时隐藏控制视图
    [self qy_showThenHideControlViewWithAnimated:YES];
}

#pragma mark - Animation
- (void)qy_showThenHideControlViewWithAnimated:(BOOL)animated {
    // 防止从 锁屏->解锁, 延时方法还会调用
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(qy_delayHideLockButton)
                                               object:nil];
    if (!self.lockBtn.selected) { // 解锁状态下
        [self qy_showControlViewWithAnimated:animated];
        [self qy_delayHideControlView:kDelayInterval animated:animated];
        return;
    }
    // 锁屏
    [self qy_hideControlViewWithAnimated:NO];
    self.lockBtn.hidden = NO;
    [self performSelector:@selector(qy_delayHideLockButton)
               withObject:nil
               afterDelay:kDelayInterval];
}
// 延时隐藏锁
- (void)qy_delayHideLockButton {
    self.lockBtn.hidden = YES;
}
/**
 延时隐藏控制视图 (私)
 @param duration 持续时间
 @param animated 是否动画
 */
- (void)qy_delayHideControlView:(NSTimeInterval)duration animated:(BOOL)animated {
    // 每次调用取消以前的操作 从新计时
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(qy_delayHideWithAnimated:)
                                               object:@(animated)];
    [self performSelector:@selector(qy_delayHideWithAnimated:)
               withObject:@(animated)
               afterDelay:duration];
}
- (void)qy_delayHideWithAnimated:(NSNumber *)animated {
    [self qy_hideControlViewWithAnimated:[animated boolValue]];
}
/**
 显示控制视图 (私)
 @param animated 是否动画
 */
- (void)qy_showControlViewWithAnimated:(BOOL)animated {
    if (self.isShowControlView) return;
    if (self.isFullscreen) _lockBtn.hidden = NO;
    if (animated) {
        [UIView animateWithDuration:kAnimationInterval animations:^{
            self->_navView.alpha = 1.f;
            self->_bottomView.alpha = 1.f;
        }];
    } else {
        _navView.alpha = 1.f;
        _bottomView.alpha = 1.f;
    }
    _isShowControlView = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:animated];
#pragma clang diagnostic pop
}
/**
 隐藏控制视图 (私)
 @param animated 是否动画
 */
- (void)qy_hideControlViewWithAnimated:(BOOL)animated {
    if (!_isShowControlView) return;
    if (animated) {
        [UIView animateWithDuration:kAnimationInterval animations:^{
            self->_navView.alpha = 0.f;
            self->_bottomView.alpha = 0.f;
        }];
    } else {
        _navView.alpha = 0.f;
        _bottomView.alpha = 0.f;
    }
    if (self.isFullscreen) self->_lockBtn.hidden = YES;
    _isShowControlView = NO;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:animated];
#pragma clang diagnostic pop
}

#pragma mark - Setter
- (void)setIsFullscreen:(BOOL)isFullscreen {
    if (_isFullscreen == isFullscreen) return;
    _isFullscreen = isFullscreen;
    // 刷新UI
    [self refreshControlViewUI];
}

#pragma mark - Getter
// 顶部导航层视图
- (UIView *)navView {
    if (!_navView) _navView = [UIView new];
    return _navView;
}
- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"player_back"]
                  forState:UIControlStateNormal];
        [_backBtn addTarget:self
                     action:@selector(buttonOnClick:)
           forControlEvents:UIControlEventTouchUpInside];
        _backBtn.tag = kButtonTagBaseValue + QYPlayerControlViewEvent_Back;
    }
    return _backBtn;
}
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont systemFontOfSize:15.f];
        _titleLab.textColor = [UIColor whiteColor];
    }
    return _titleLab;
}
- (UIButton *)castBtn {
    if (!_castBtn) {
        _castBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_castBtn setImage:[UIImage imageNamed:@"player_cast"]
                  forState:UIControlStateNormal];
        [_castBtn addTarget:self
                     action:@selector(buttonOnClick:)
           forControlEvents:UIControlEventTouchUpInside];
        _castBtn.tag = kButtonTagBaseValue + QYPlayerControlViewEvent_Cast;
    }
    return _castBtn;
}
- (UIButton *)definitionBtn {
    if (!_definitionBtn) {
        _definitionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_definitionBtn setTitleColor:[UIColor whiteColor]
                             forState:UIControlStateNormal];
        _definitionBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_definitionBtn addTarget:self
                           action:@selector(buttonOnClick:)
                 forControlEvents:UIControlEventTouchUpInside];
        _definitionBtn.tag = kButtonTagBaseValue + QYPlayerControlViewEvent_Definition;
    }
    return _definitionBtn;
}
// 底部操作按钮视图
- (UIView *)bottomView {
    if (!_bottomView) _bottomView = [UIView new];
    return _bottomView;
}
- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"player_play"]
                  forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"player_pause"]
                  forState:UIControlStateSelected];
        [_playBtn addTarget:self
                     action:@selector(buttonOnClick:)
           forControlEvents:UIControlEventTouchUpInside];
        _playBtn.tag = kButtonTagBaseValue + QYPlayerControlViewEvent_Play;
    }
    return _playBtn;
}
- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setImage:[UIImage imageNamed:@"player_next"]
                  forState:UIControlStateNormal];
        [_nextBtn addTarget:self
                     action:@selector(buttonOnClick:)
           forControlEvents:UIControlEventTouchUpInside];
        _nextBtn.tag = kButtonTagBaseValue + QYPlayerControlViewEvent_Next;
    }
    return _nextBtn;
}
- (UILabel *)currentTimeLab {
    if (!_currentTimeLab) {
        _currentTimeLab = [UILabel new];
        _currentTimeLab.font = [UIFont systemFontOfSize:13.f];
        _currentTimeLab.textAlignment = NSTextAlignmentCenter;
        _currentTimeLab.textColor = [UIColor whiteColor];
        _currentTimeLab.text = @"00:00";
    }
    return _currentTimeLab;
}
- (UILabel *)totalTimeLab {
    if (!_totalTimeLab) {
        _totalTimeLab = [UILabel new];
        _totalTimeLab.font = [UIFont systemFontOfSize:13.f];
        _totalTimeLab.textAlignment = NSTextAlignmentCenter;
        _totalTimeLab.textColor = [UIColor whiteColor];
        _totalTimeLab.text = @"00:00";
    }
    return _totalTimeLab;
}
- (UIButton *)fullscreenBtn {
    if (!_fullscreenBtn) {
        _fullscreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullscreenBtn setImage:[UIImage imageNamed:@"player_fullscreen"]
                        forState:UIControlStateNormal];
        [_fullscreenBtn addTarget:self
                           action:@selector(buttonOnClick:)
                 forControlEvents:UIControlEventTouchUpInside];
        _fullscreenBtn.tag = kButtonTagBaseValue + QYPlayerControlViewEvent_Fullscreen;
    }
    return _fullscreenBtn;
}
- (QYPlayerProgress *)progressBar {
    if (!_progressBar) {
        _progressBar = [QYPlayerProgress new];
        _progressBar.delegate = self;
    }
    return _progressBar;
}
- (UIButton *)lockBtn {
    if (!_lockBtn) {
        _lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockBtn setImage:[UIImage imageNamed:@"player_unlock"]
                  forState:UIControlStateNormal];
        [_lockBtn setImage:[UIImage imageNamed:@"player_lock"]
                  forState:UIControlStateSelected];
        [_lockBtn addTarget:self
                     action:@selector(buttonOnClick:)
           forControlEvents:UIControlEventTouchUpInside];
        _lockBtn.tag = kButtonTagBaseValue + QYPlayerControlViewEvent_lock;
    }
    return _lockBtn;
}

@end
