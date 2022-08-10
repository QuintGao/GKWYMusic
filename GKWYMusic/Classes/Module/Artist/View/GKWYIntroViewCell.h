//
//  GKWYIntroViewCell.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/18.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYArtistModel.h"
#import "GKWYArtistRecModel.h"

static NSString *const kWYIntroViewCellID = @"GKWYIntroViewCell";

@interface GKWYIntroViewCell : UITableViewCell

@property (nonatomic, strong) GKWYArtistDescModel *model;

@end
