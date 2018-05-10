//
//  GKVolumeView.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface GKVolumeView : MPVolumeView

@property (nonatomic, assign) float volumeValue;

@property (nonatomic, copy) void(^valueChanged)(float value);

- (void)getValue;

@end
