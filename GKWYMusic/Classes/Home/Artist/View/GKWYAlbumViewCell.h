//
//  GKWYAlbumViewCell.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/4.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYResultModel.h"
#import "GKWYAlbumModel.h"

static NSString *const kAlbumViewCellID = @"GKWYAlbumViewCell";

@interface GKWYAlbumViewCell : UITableViewCell

@property (nonatomic, strong) GKWYResultAlbumModel *model;

@property (nonatomic, strong) GKWYAlbumModel *albumModel;

@end
