//
//  NSString+Custom.m
//  QYVideoPlayer
//
//  Created by Joeyoung on 2019/1/21.
//  Copyright © 2019 Joeyoung. All rights reserved.
//

#import "NSString+Custom.h"

@implementation NSString (Custom)

// 时间的分和秒进行可视化.
+ (instancetype)qy_timeformatFromSeconds:(NSTimeInterval)seconds {
    int minute = (int)seconds/60;
    int second = (int)seconds%60;
    if (minute < 100) {
        NSString *time = [NSString stringWithFormat:@"%.2d:%.2d", minute, second];
        return time;
    } else {
        NSString *time = [NSString stringWithFormat:@"%d:%.2d", minute, second];
        return time;
    }
}

@end
