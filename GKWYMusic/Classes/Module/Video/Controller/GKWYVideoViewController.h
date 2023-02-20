//
//  GKWYVideoViewController.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/29.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYBaseViewController.h"
#import "GKWYVideoModel.h"

@interface GKWYVideoViewController : GKWYBaseViewController

@property (nonatomic, strong) GKWYVideoModel *model;
@property (nonatomic, copy) NSString *mv_id;
@property (nonatomic, copy) NSString *song_id;

@end
