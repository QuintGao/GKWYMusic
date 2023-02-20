//
//  GKWYArtistViewController.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/15.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYBaseViewController.h"
#import "GKWYArtistModel.h"

@interface GKWYArtistViewController : GKWYBaseViewController

@property (nonatomic, copy) NSString *artist_id;

@property (nonatomic, strong) GKWYArtistModel *model;

@end
