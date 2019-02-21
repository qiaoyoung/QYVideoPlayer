//
//  NSTimer+QYBlockSupport.m
//  Study Test
//
//  Created by Joeyoung on 16/10/24.
//  Copyright © 2016年 Joeyoung. All rights reserved.
//

#import "NSTimer+QYBlockSupport.h"

@implementation NSTimer (QYBlockSupport)


+ (NSTimer *)qy_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                       repeats:(BOOL)repeats
                                         block:(void(^)(void))block {
  return  [self scheduledTimerWithTimeInterval:interval
                                        target:self
                                      selector:@selector(qy_blockInvoke:)
                                      userInfo:[block copy]
                                       repeats:repeats];
}

+ (void)qy_blockInvoke:(NSTimer *)timer {
    void(^block)(void) = timer.userInfo;
    if (block) {
        block();
    }
}

@end
