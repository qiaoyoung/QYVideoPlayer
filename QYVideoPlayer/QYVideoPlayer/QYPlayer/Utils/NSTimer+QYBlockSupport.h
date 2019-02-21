//
//  NSTimer+QYBlockSupport.h
//  Study Test
//
//  Created by Joeyoung on 16/10/24.
//  Copyright © 2016年 Joeyoung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (QYBlockSupport)

+ (NSTimer *)qy_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                       repeats:(BOOL)repeats
                                         block:(void(^)(void))block;

@end
