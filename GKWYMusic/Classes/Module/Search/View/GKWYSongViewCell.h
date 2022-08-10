//
//  GKWYSongViewCell.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/4.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYResultModel.h"

@interface GKWYSongItemView : UIView

@property (nonatomic, strong) GKWYMusicModel *model;
@property (nonatomic, copy) void(^itemClickBlock)(id model);
@property (nonatomic, copy) void(^moreClickBlock)(id model);

@end

@interface GKWYSongViewCell : UITableViewCell

@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) GKWYMusicModel *model;

@end
