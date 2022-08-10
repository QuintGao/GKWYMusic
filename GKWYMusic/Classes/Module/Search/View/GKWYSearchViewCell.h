//
//  GKWYSearchViewCell.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/24.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const kGKWYSearchViewCellID = @"GKWYSearchViewCell";

@interface GKWYSearchViewCell : UITableViewCell

@property (nonatomic, copy) NSString *text;

@property (nonatomic, copy) void(^deleteClickBlock)(void);

@end
