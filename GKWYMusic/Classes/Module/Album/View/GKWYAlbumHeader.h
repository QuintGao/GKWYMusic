//
//  GKWYAlbumHeader.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/11.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKWYAlbumModel.h"

@interface GKWYAlbumHeader : UIView

@property (nonatomic, strong) UILabel        *albumNameLabel;    // 专辑名称

@property (nonatomic, strong) GKWYAlbumModel *model;

@end
