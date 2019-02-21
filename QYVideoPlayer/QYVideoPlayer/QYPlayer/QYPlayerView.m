//
//  QYPlayerView.m
//  QYVideoPlayer
//
//  Created by Joeyoung on 2019/1/18.
//  Copyright © 2019 Joeyoung. All rights reserved.
//

#import "QYPlayerView.h"
#import "QYPlayerView+Rotation.h"
#import "QYPlayerView+Gesture.h"
#import "QYPlayerDefine.h"

@interface QYPlayerView ()<QYPlayerControlViewDelegate>

/** 观察者监听事件的变化 */
@property (nonatomic, strong) id playerObserver;
/** 播放器 */
@property (nonatomic, strong) AVPlayer *player;
/** 播放器视图 */
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
/** 播放元素 */
@property (nonatomic, strong) AVPlayerItem *playerItem;

@end

@implementation QYPlayerView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        self.playerItem = nil;
    }
    if (self.playerObserver) {
        [self.player removeTimeObserver:self.playerObserver];
        self.playerObserver = nil;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _playerLayer.frame = self.bounds;
    _controlView.frame = self.bounds;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化播放器配置
        self.player = [AVPlayer playerWithPlayerItem:nil];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        // 视频内容展示比例
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:self.playerLayer];
        // 视频播放控制视图
        self.controlView = [QYPlayerControlView new];
        self.controlView.delegate = self;
        [self addSubview:self.controlView];
        // 屏幕旋转配置
        [self qy_setupRotation];
        // 手势配置
        [self qy_setupGesture];
    }
    return self;
}

#pragma mark - Event
- (void)qy_loadVideo:(NSString *)string {
    if (!string || string.length == 0) return;
    // 停止以前的操作
    if (self.playerItem) [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.controlView.playBtn.selected = NO;
    self.controlView.currentTimeLab.text = @"00:00";
    self.controlView.totalTimeLab.text = @"00:00";
 
    // 初始化playerItem 并监听状态变化
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:string]];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.playerItem && [keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] intValue];
        switch (status) {
            case AVPlayerItemStatusUnknown:
                NSLog(@"AVPlayerItemStatusUnknown");
                [self.player replaceCurrentItemWithPlayerItem:nil];
                self.controlView.playBtn.selected = NO;
                break;
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"AVPlayerItemStatusReadyToPlay");
                [self.player play];
                // 同步状态到控制层
                self.controlView.playBtn.selected = YES;
                [self.controlView qy_showThenHideControlViewWithAnimated:YES];
                 // 更新播放进度
                [self qy_updateProgress];
                break;
            case AVPlayerItemStatusFailed:
                NSLog(@"AVPlayerItemStatusFailed :%@", self.playerItem.error);
                [self.player replaceCurrentItemWithPlayerItem:nil];
                self.controlView.playBtn.selected = NO;
                break;
            default:
                break;
        }
    }
}
// 更新视频播放进度
- (void)qy_updateProgress {
    __weak typeof(self) weakSelf = self;
    [self.player removeTimeObserver:self.playerObserver];
    self.playerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        if (CMTIME_IS_NUMERIC(weakSelf.playerItem.currentTime) && CMTIME_IS_NUMERIC(weakSelf.playerItem.duration)) {
            CGFloat currentSeconds = CMTimeGetSeconds(weakSelf.playerItem.currentTime);
            CGFloat durationSeconds = CMTimeGetSeconds(weakSelf.playerItem.duration);
            // 更新播放显示进度
            weakSelf.controlView.progressBar.playValue = currentSeconds;
            weakSelf.controlView.progressBar.maximumValue = durationSeconds;
            weakSelf.controlView.progressBar.bufferValue = [weakSelf qy_getBufferProgress]/durationSeconds;
            weakSelf.controlView.currentTimeLab.text = [NSString qy_timeformatFromSeconds:currentSeconds];
            weakSelf.controlView.totalTimeLab.text = [NSString qy_timeformatFromSeconds:durationSeconds];
        }
    }];
}
// 获取缓冲进度
- (NSTimeInterval)qy_getBufferProgress {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    CGFloat startSeconds = CMTimeGetSeconds(timeRange.start);
    CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    result = isnan(result) ? 0.f:result; // 防止出现NaN
    return result;
}

#pragma mark - QYPlayerControlViewDelegate
- (void)qy_PlayerControlViewButtonClickWithEvent:(QYPlayerControlViewEvent)event {
    switch (event) {
        case QYPlayerControlViewEvent_Back: // 返回
            NSLog(@"QYPlayerControlViewEvent_Back:返回到上级视图");
            break;
        case QYPlayerControlViewEvent_Definition: // 清晰度
            NSLog(@"QYPlayerControlViewEvent_Definition:切换清晰度");
            break;
        case QYPlayerControlViewEvent_Cast: // 投屏
            NSLog(@"QYPlayerControlViewEvent_Cast:投屏");
            break;
        case QYPlayerControlViewEvent_Play: // 播放
            [self.player play];
            break;
        case QYPlayerControlViewEvent_Pause: // 暂停
            [self.player pause];
            break;
        case QYPlayerControlViewEvent_Next: // 下一首
            NSLog(@"QYPlayerControlViewEvent_Next:下一首");
            break;
        case QYPlayerControlViewEvent_Seek:{ // 播放进度
            [self.player pause];
            __weak typeof(self) weakSelf = self;
            [self.player seekToTime:CMTimeMake(self.controlView.progressBar.playValue, 1.) completionHandler:^(BOOL finished) {
                [weakSelf.player play];
                // 同步状态到控制层
                weakSelf.controlView.playBtn.selected = YES;
                [weakSelf.controlView qy_showThenHideControlViewWithAnimated:YES];
             }];
            break;
        }
        case QYPlayerControlViewEvent_Fullscreen: // 全屏
            [self qy_setOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            self.controlView.isFullscreen = YES;
            break;
        case QYPlayerControlViewEvent_Smallscreen: // 小屏
            [self qy_setOrientation:UIInterfaceOrientationPortrait animated:YES];
            self.controlView.isFullscreen = NO;
            break;
        case QYPlayerControlViewEvent_lock: // 锁屏
            self.isLockScreen = YES;
            break;
        case QYPlayerControlViewEvent_unlock: // 解锁屏
            self.isLockScreen = NO;
            break;
        default:
            break;
    }
}

#pragma mark - Setter
- (void)setTitle:(NSString *)title {
    if (_title == title) return;
    _title = [title copy];
    self.controlView.titleLab.text = _title;
}
- (void)setDefinition:(NSString *)definition {
    if (_definition == definition) return;
    _definition = [definition copy];
    [self.controlView.definitionBtn setTitle:_definition forState:UIControlStateNormal];
}

@end
