//
//  GKWYSongViewCell.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/4.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYResultModel.h"

static NSString *const kSongViewCellID = @"GKWYSongViewCell";

@interface GKWYSongViewCell : UITableViewCell

@property (nonatomic, strong) GKWYSongModel *model;

@end
