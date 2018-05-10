//
//  GKWYMyListViewCell.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/4.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const kMyListViewCellID = @"GKWYMyListViewCell";

@interface GKWYMyListViewCell : UITableViewCell

@property (nonatomic, strong) GKWYMusicModel *model;

@end
