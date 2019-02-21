//
//  QYPlayerProgress.h
//  QYVideoPlayer
//
//  Created by Joeyoung on 2019/2/1.
//  Copyright © 2019 Joeyoung. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QYPlayerProgressDelegate <NSObject>

/**
 播放进度条的值发生改变
 */
- (void)qy_playProgressValueChanged;

@end

@interface QYPlayerProgress : UIView

/** delegate */
@property(nonatomic, weak) id<QYPlayerProgressDelegate> delegate;
/** 播放进度 */
@property (nonatomic, assign) CGFloat playValue;
/** 缓冲进度 */
@property (nonatomic, assign) CGFloat bufferValue;
/** 最大时间 */
@property (nonatomic, assign) CGFloat maximumValue;

@end

NS_ASSUME_NONNULL_END
