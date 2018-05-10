//
//  GKWYRecommendViewCell.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/22.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const kGKWYRecommendViewCell = @"GKWYRecommendViewCell";

@interface GKWYRecommendViewCell : UITableViewCell

@property (nonatomic, strong) GKWYMusicModel *model;

@property (nonatomic, assign) NSInteger row;

@property (nonatomic, copy) void(^moreClicked)(GKWYMusicModel *model);

@end
