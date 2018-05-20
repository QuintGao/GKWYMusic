//
//  GKWYArtistMainTableView.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/19.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYArtistMainTableView.h"

@implementation GKWYArtistMainTableView

// 是否允许支持多个手势，默认NO
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
