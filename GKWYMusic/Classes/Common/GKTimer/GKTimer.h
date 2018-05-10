//
//  GKTimer.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/2.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^GKTimerBlock)(id userInfo);

@interface GKTimer : NSObject

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval
                                    target:(id)target
                                  selector:(SEL)selector
                                  userInfo:(id)userInfo
                                   repeats:(BOOL)repeats;

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval
                                     block:(GKTimerBlock)block
                                  userInfo:(id)userInfo
                                   repeats:(BOOL)repeats;

@end
