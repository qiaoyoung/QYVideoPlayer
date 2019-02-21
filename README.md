# QYVideoPlayer
一个简单的视频播放器，输入视频资源地址，即可播放该视频。
![](https://upload-images.jianshu.io/upload_images/3265534-76009787f3bd26f7.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)       
最近工作之余, 写了一个视频播放器，输入要播放的视频资源地址，即可实现播放功能。
目前功能比较简单，支持锁屏、屏幕旋转等基础功能，后续会继续完善。。。

下面讲解下实现思路：
## 一、 框架选择：<AVFoundation/AVFoundation.h>
因 `<MediaPlayer/MediaPlayer.h>` 中 `MPMoviePlayerController
MP_DEPRECATED("Use AVPlayerViewController in AVKit.", ios(2.0, 9.0))` 在iOS9以后已经废弃，为了更好的兼容性，采用了 `<AVFoundation/AVFoundation.h>` 为技术实现方案。
## 二、AVFoundation框架分析：
框架在此就不讲解了，官网讲的比较清楚，不懂的可以查看官档。[-> 戳这里](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/00_Introduction.html#//apple_ref/doc/uid/TP40010188-CH1-SW3)

## 三、源码解析：
### 1. `QYPlayerView` 类：
* 作用：
负责视频播放视图的展示，设置视频的名称、清晰度，获取设备方向、是否锁屏等操作。在`ViewController` 中的使用如下：
```
// 实例化
- (QYPlayerView *)playerView {
if (!_playerView) {
CGRect rect = CGRectMake(0, 0, kScreenWidth, kScreenWidth*9/16);
_playerView = [[QYPlayerView alloc] initWithFrame:rect];
_playerView.backgroundColor = [UIColor blackColor];
_playerView.layer.borderColor = [UIColor blackColor].CGColor;
_playerView.layer.borderWidth = 0.5f;
_playerView.title = @"视频播放器";
}
return _playerView;
}
...
// 添加到父视图
[self.view addSubview:self.playerView];
// 加载视频资源
[self.playerView qy_loadVideo:textField.text];
```
* 源码解析：
继承自UIView，负责播放器 `AVPlayer`、播放器视图 `AVPlayerLayer` 、播放器元素 `AVPlayerItem` 的初始化操作。
```
// 初始化playerItem 并监听状态变化
self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:string]];
[self.player replaceCurrentItemWithPlayerItem:self.playerItem];
[self.playerItem addObserver:self
forKeyPath:@"status"
options:NSKeyValueObservingOptionNew
context:nil];
```
监听视频资源的加载状态, 根据不同的状态进行相应的操作。
```
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
```
更新视频资源的播放进度。
```
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
```
实现控制视图 `QYPlayerControlView` 的Delegate。 当控制视图进行了相应操作，事件被传递到该类中进行统一处理。
```
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
```
### 2. `QYPlayerControlView` 类：
* 作用：
对视频播放器进行控制。功能如枚举中所列 (部分还未实现) ：
```
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
```
![](https://upload-images.jianshu.io/upload_images/3265534-8fbd34f6d0ee8153.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
* 源码解析：
继承自UIView，放在  `QYPlayerView` 视图上面，负责用户对播放视频的操作动作。
UI布局采用的约束，方便屏幕旋转时，约束自动调整布局。（省事）
把枚举值绑定到对应控件的tag上，方便分辨所操作的控件。
```
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
```
该类中还有对操作视图 显示/隐藏 的方法。
```
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
```
### 3. `QYPlayerView+Rotation` 分类：
* 作用：
控制视频播放器的旋转。
* 源码解析：
`QYPlayerView` 分类的实现，代码高聚合，低耦合。先初始化设备方向，然后添加旋转监听。当设备方向变化时，同步视频播放器视图的方向。
```
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
...
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
```
### 4. `QYPlayerView+Gesture` 分类：
* 作用：
控制视频播放器相关的手势操作。
* 源码解析：
`QYPlayerView` 分类的实现，代码高聚合，低耦合。
目前只添加了点击手势。控制视图会自动隐藏。当用户点击屏幕时，展示控制视图。
```
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
```
后续调整视频亮度、音量、进度等手势都需添加在该分类中，便于统一管理。
### 5. `Utils` 文件夹：
主要存放时间转换的分类`NSString+Custom`、常用宏`QYPlayerDefine` 等工具类。

### 添加屏幕旋转功能:
1). `BaseViewController` 中实现了控制屏幕旋转的系统方法，实现的控制器要继承自 `BaseViewController` 。
```
// Interface的方向是否会跟随设备方向自动旋转，如果返回NO,后两个方法不会再调用
- (BOOL)shouldAutorotate {
return YES;
}
// 返回直接支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
return UIInterfaceOrientationMaskAllButUpsideDown;
}
// 返回最优先显示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
return UIInterfaceOrientationPortrait;
}
```

2). 在子控制器中实现如下方法。
```
// 在需要全屏的控制器中实现该方法, 控制锁屏功能
- (BOOL)shouldAutorotate {
return !_playerView.isLockScreen;
} 
```
此时屏幕旋转功能已经添加成功！

***
以上便是整个播放器的源码解析，具体的细节请查看源码。
***

千里之行，始于足下。
