//
//  GKWYSearchViewCell.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/24.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYTagModel.h"

static NSString *const kGKWYSearchViewCellID = @"GKWYSearchViewCell";

@interface GKWYSearchViewCell : UITableViewCell

@property (nonatomic, strong) GKWYTagModel *model;

@property (nonatomic, copy) void(^deleteClickBlock)(void);

@end
