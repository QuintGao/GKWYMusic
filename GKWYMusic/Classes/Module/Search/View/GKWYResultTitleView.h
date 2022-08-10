//
//  GKWYResultTitleView.h
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/2.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYResultModel.h"

NS_ASSUME_NONNULL_BEGIN

// 基类
@interface GKWYResultTitleView : UIView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, copy) void(^showMoreBlock)(void);
@property (nonatomic, copy) void(^itemClickBlock)(id mdoel);

- (CGFloat)heightWithModel:(id)model;
- (void)moreAction;

@end

// 歌曲
@interface GKWYResultSongView : GKWYResultTitleView

@end

// 歌单
@interface GKWYResultPlayListView : GKWYResultTitleView

@end

// 专辑
@interface GKWYResultAlbumView : GKWYResultTitleView

@end

NS_ASSUME_NONNULL_END
