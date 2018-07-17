//
//  GKWYListViewCell.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/22.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYResultModel.h"

static NSString *const kGKWYListViewCell = @"GKWYListViewCell";

@class GKWYListViewCell;

@protocol GKWYListViewCellDelegate<NSObject>

@optional
- (void)cellDidClickMVBtn:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model;

- (void)cellDidClickNextItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model;
- (void)cellDidClickShareItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model;
- (void)cellDidClickDownloadItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model;
- (void)cellDidClickCommentItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model;
- (void)cellDidClickLoveItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model;
- (void)cellDidClickArtistItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model;
- (void)cellDidClickAlbumItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model;
- (void)cellDidClickMVItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model;

@end

@interface GKWYListViewCell : UITableViewCell

@property (nonatomic, weak) id<GKWYListViewCellDelegate> delegate;

@property (nonatomic, strong) GKWYMusicModel *model;

// 搜索结果页使用
@property (nonatomic, strong) GKWYMusicModel *songModel;

@property (nonatomic, assign) BOOL isAlbum; // 是否是专辑详情页

@property (nonatomic, assign) NSInteger row;

@end
