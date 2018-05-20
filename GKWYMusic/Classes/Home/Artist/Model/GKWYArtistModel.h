//
//  GKWYArtistModel.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/15.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GKWYArtistModel : NSObject

@property (nonatomic, strong) NSString *ting_uid;
@property (nonatomic, strong) NSString *avatar_s500;
@property (nonatomic, strong) NSString *listen_num;
@property (nonatomic, strong) NSString *collect_num;
@property (nonatomic, strong) NSString *albums_total;
@property (nonatomic, strong) NSString *artist_id;
@property (nonatomic, strong) NSString *intro;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *mv_total;
@property (nonatomic, strong) NSString *share_num;
@property (nonatomic, strong) NSString *songs_total;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSAttributedString *introAttr;

@property (nonatomic, assign) CGFloat           introHeight;
@property (nonatomic, assign) BOOL              hasMoreIntro;

@end
