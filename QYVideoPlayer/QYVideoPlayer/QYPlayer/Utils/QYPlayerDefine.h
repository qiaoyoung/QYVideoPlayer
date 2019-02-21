//
//  QYPlayerDefine.h
//  QYVideoPlayer
//
//  Created by Joeyoung on 2019/1/21.
//  Copyright © 2019 Joeyoung. All rights reserved.
//

#ifndef QYPlayerDefine_h
#define QYPlayerDefine_h

#endif /* QYPlayerDefine_h */

#import "NSString+Custom.h"
#import "NSTimer+QYBlockSupport.h"
#import <Masonry.h>

// 屏幕宽度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define kScreenHight [UIScreen mainScreen].bounds.size.height
// 状态栏高度
#define kStatusbarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
/**
 判断机型是否为iPhoneX系列, 包括(iPhoneX, iPhoneXS, iPhoneXr, iPhoneXs Max)
 */
#define kIsiPhoneXSeries ([UIScreen mainScreen].bounds.size.height == 812.0 || [UIScreen mainScreen].bounds.size.width == 812.0 || [UIScreen mainScreen].bounds.size.height == 896.0 || [UIScreen mainScreen].bounds.size.width == 896.0) ? YES:NO
/**
 安全区域头部距离 iPhoneX系列为44，其他为0
 */
#define kSafeAreaTop ((kIsiPhoneXSeries) ? 44.0 : 0)
/**
 安全区域底部距离 iPhoneX系列为34，其他为0
 */
#define kSafeAreaBottom ((kIsiPhoneXSeries) ? 34.0 : 0)
