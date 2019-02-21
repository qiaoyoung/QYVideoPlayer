//
//  NSString+Custom.h
//  QYVideoPlayer
//
//  Created by Joeyoung on 2019/1/21.
//  Copyright © 2019 Joeyoung. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Custom)

// 秒 =>  "xx:xx"
+ (instancetype)qy_timeformatFromSeconds:(NSTimeInterval)seconds;

@end

NS_ASSUME_NONNULL_END
