//
//  GKWYMusicCoverView.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^finished)(void);

@protocol GKWYMusicCoverViewDelegate<NSObject>

@optional
- (void)scrollDidScroll;
- (void)scrollWillChangeModel:(GKWYMusicModel *)model;
- (void)scrollDidChangeModel:(GKWYMusicModel *)model;

@end

@interface GKWYMusicCoverView : UIView

@property (nonatomic, weak) id<GKWYMusicCoverViewDelegate> delegate;

/**
 切换唱片的scrollView
 */
@property (nonatomic, strong) UIScrollView *diskScrollView;

// 初始化coverView列表
- (void)initMusicList:(NSArray *)musics idx:(NSInteger)currentIndex;

// 重置coverView列表
- (void)resetMusicList:(NSArray *)musics idx:(NSInteger)currentIndex;

/**
 滑动切换歌曲

 @param isNext 是否是下一曲（YES：是 NO：不是，表示上一首）
 @param finished 切换完成的回调
 */
- (void)scrollChangeDiskIsNext:(BOOL)isNext finished:(finished)finished;

/** 播放 */
- (void)playedWithAnimated:(BOOL)animated;
/** 暂停 */
- (void)pausedWithAnimated:(BOOL)animated;

/** 重置试图 */
- (void)resetCoverView;

@end
