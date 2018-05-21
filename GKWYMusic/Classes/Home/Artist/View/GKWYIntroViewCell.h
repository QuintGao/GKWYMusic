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

@property (nonatomic, strong) GKWYArtistModel *artistModel;
@property (nonatomic, strong) NSArray           *dataList;

@property (nonatomic, copy) void(^introBtnClickBlock)(void);
@property (nonatomic, copy) void(^recArtistClickBlock)(GKWYArtistRecModel *model);

@end

@interface GKWYArtistRecView : UIView

@property (nonatomic, strong) GKWYArtistRecModel *recModel;

@end
