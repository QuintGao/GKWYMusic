//
//  GKWYVideoViewCell.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/17.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYVideoModel.h"

static NSString *const kWYVideoViewCellID = @"GKWYVideoViewCell";

@interface GKWYVideoViewCell : UITableViewCell

@property (nonatomic, strong) GKWYVideoModel *model;

@end
