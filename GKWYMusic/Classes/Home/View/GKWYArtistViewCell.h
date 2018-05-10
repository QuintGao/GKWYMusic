//
//  GKWYArtistViewCell.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/4.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYResultModel.h"

static NSString *const kArtistViewCellID = @"GKWYArtistViewCell";

@interface GKWYArtistViewCell : UITableViewCell

@property (nonatomic, strong) GKWYArtistModel *model;

@end
