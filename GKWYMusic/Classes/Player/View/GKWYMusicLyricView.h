//
//  GKWYMusicLyricView.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKLyricParser.h"

@interface GKWYMusicLyricView : UIView

/** 歌词信息 */
@property (nonatomic, strong) NSArray *lyrics;
@property (nonatomic, assign) NSInteger lyricIndex;

/** 是否将要拖拽歌词 */
@property (nonatomic, assign) BOOL isWillDraging;

/** 是否正在滚动歌词 */
@property (nonatomic, assign) BOOL isScrolling;

/** 声音视图滑动开始或结束block */
@property (nonatomic, copy) void(^volumeViewSliderBlock)(BOOL isBegan);

/**
 滑动歌词的方法
 
 @param currentTime 当前时间
 @param totalTime 总时间
 */
- (void)scrollLyricWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

/**
 隐藏系统音量试图
 */
- (void)hideSystemVolumeView;

/**
 显示系统音量试图
 */
- (void)showSystemVolumeView;

@end
