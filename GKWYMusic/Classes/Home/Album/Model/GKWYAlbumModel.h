//
//  GKWYAlbumModel.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/11.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GKWYAlbumModel : NSObject

@property (nonatomic, copy) NSString *album_id;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *songs_total;
@property (nonatomic, copy) NSString *info;
@property (nonatomic, copy) NSString *publishtime;
@property (nonatomic, copy) NSString *artist_ting_uid;
@property (nonatomic, copy) NSString *favorites_num;
@property (nonatomic, copy) NSString *recommend_num;
@property (nonatomic, copy) NSString *collect_num;
@property (nonatomic, copy) NSString *share_num;
@property (nonatomic, copy) NSString *comment_num;
@property (nonatomic, copy) NSString *pic_radio;
@property (nonatomic, copy) NSString *pic_small;
@property (nonatomic, copy) NSString *pic_big;
@property (nonatomic, copy) NSString *pic_s180;
@property (nonatomic, copy) NSString *artist_id;
@property (nonatomic, copy) NSString *all_artist_id;

@end
