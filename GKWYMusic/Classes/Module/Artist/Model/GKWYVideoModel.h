//
//  GKWYVideoModel.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/17.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKWYArtistModel.h"

@interface GKWYVideoModel : NSObject

@property (nonatomic, copy) NSString *video_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *artistName;
@property (nonatomic, strong) GKWYArtistModel *artist;

@property (nonatomic, copy) NSString *imgurl;
@property (nonatomic, copy) NSString *imgurl16v9;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *playCount;
@property (nonatomic, copy) NSString *publishTime;

@property (nonatomic, copy) NSString *durationStr;
@property (nonatomic, copy) NSString *playCountStr;

@property (nonatomic, assign) CGFloat cellHeight;

@end
