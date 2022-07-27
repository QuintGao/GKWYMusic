//
//  GKWYDiskView.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKWYDiskView : UIView

- (instancetype)initDesktopView;

@property (nonatomic, strong)   UIImageView *diskImgView;

@property (nonatomic, copy)     NSString *imgUrl;

@property (nonatomic, strong) GKWYMusicModel    *model;

@end
