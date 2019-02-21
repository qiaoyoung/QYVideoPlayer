//
//  QYPlayerProgress.m
//  QYVideoPlayer
//
//  Created by Joeyoung on 2019/2/1.
//  Copyright © 2019 Joeyoung. All rights reserved.
//

#import "QYPlayerProgress.h"
@interface QYPlayerProgress ()

/** 播放进度条 */
@property (nonatomic, strong) UISlider *playSlider;
/** 缓冲进度条 */
@property (nonatomic, strong) UIProgressView *bufferProgress;

@end

@implementation QYPlayerProgress

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createProgressView];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    _bufferProgress.frame = CGRectMake(2, self.bounds.size.height/2-1, self.bounds.size.width-2, self.bounds.size.height/2);
    _playSlider.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}

#pragma mark - UI
- (void)createProgressView {
    [self addSubview:self.bufferProgress];
    [self addSubview:self.playSlider];
}

#pragma mark - Event
- (void)qy_sliderValueChanged:(UISlider *)slider {
    _playValue = slider.value;
    if (_delegate && [_delegate respondsToSelector:@selector(qy_playProgressValueChanged)]) {
        [self.delegate qy_playProgressValueChanged];
    }
}

#pragma mark - Setter
- (void)setPlayValue:(CGFloat)playValue {
    if (!_playSlider.isTracking) _playSlider.value = playValue;
}
- (void)setBufferValue:(CGFloat)bufferValue {
    _bufferProgress.progress = bufferValue;
}
- (void)setMaximumValue:(CGFloat)maximumValue {
    if (_playSlider.maximumValue == maximumValue) return;
    _playSlider.maximumValue = maximumValue;
}
#pragma mark - Getter
- (UISlider *)playSlider {
    if (!_playSlider) {
        _playSlider = [UISlider new];
        [_playSlider setThumbImage:[UIImage imageNamed:@"player_progressThumb"]
                           forState:UIControlStateNormal];
        _playSlider.minimumTrackTintColor = [UIColor orangeColor];
        _playSlider.maximumTrackTintColor = [UIColor clearColor];
        _playSlider.continuous = NO; // 结束拖拽才响应事件
        [_playSlider addTarget:self
                        action:@selector(qy_sliderValueChanged:)
              forControlEvents:UIControlEventValueChanged];
    }
    return _playSlider;
}
- (UIProgressView *)bufferProgress {
    if (!_bufferProgress) {
        _bufferProgress = [UIProgressView new];
        _bufferProgress.trackTintColor = [UIColor whiteColor];
        _bufferProgress.progressTintColor = [UIColor grayColor];
    }
    return _bufferProgress;
}

@end
