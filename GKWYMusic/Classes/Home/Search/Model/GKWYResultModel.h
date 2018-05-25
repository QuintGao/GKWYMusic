//
//  GKWYResultModel.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/3.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GKWYResultArtistInfoModel, GKWYResultSongInfoModel, GKWYResultAlbumInfoModel, GKWYResultVideoInfoModel;
@class GKWYResultArtistModel, GKWYResultSongModel, GKWYResultAlbumModel, GKWYResultVideoModel;

@interface GKWYResultModel : NSObject

@property (nonatomic, strong) GKWYResultArtistInfoModel *artist_info;
@property (nonatomic, strong) GKWYResultSongInfoModel   *song_info;
@property (nonatomic, strong) GKWYResultAlbumInfoModel  *album_info;
@property (nonatomic, strong) GKWYResultVideoInfoModel  *video_info;

@end

@interface GKWYResultArtistInfoModel : NSObject

@property (nonatomic, strong) NSArray<GKWYResultArtistModel *> *artist_list;
@property (nonatomic, assign) NSInteger *total;

@end

@interface GKWYResultArtistModel : NSObject

@property (nonatomic, copy) NSString *ting_uid;
@property (nonatomic, copy) NSString *song_num;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *avatar_middle;
@property (nonatomic, copy) NSString *album_num;
@property (nonatomic, copy) NSString *artist_desc;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *artist_source;
@property (nonatomic, copy) NSString *artist_id;

@end

@interface GKWYResultSongInfoModel : NSObject

@property (nonatomic, strong) NSArray<GKWYResultSongModel *> *song_list;
@property (nonatomic, assign) NSInteger total;

@end

@interface GKWYResultSongModel : NSObject

@property (nonatomic, copy) NSString *song_id;
@property (nonatomic, copy) NSString *ting_uid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *album_title;
@property (nonatomic, copy) NSString *artist_id;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *pic_small;
@property (nonatomic, copy) NSString *all_artist_id;
@property (nonatomic, copy) NSString *album_id;
@property (nonatomic, copy) NSString *has_mv_mobile;

@end

@interface GKWYResultAlbumInfoModel : NSObject

@property (nonatomic, strong) NSArray<GKWYResultAlbumModel *> *album_list;
@property (nonatomic, assign) NSInteger total;

@end

@interface GKWYResultAlbumModel : NSObject

@property (nonatomic, copy) NSString *album_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *all_artist_id;
@property (nonatomic, copy) NSString *publishtime;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *album_desc;
@property (nonatomic, copy) NSString *pic_small;
@property (nonatomic, copy) NSString *hot;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *artist_id;
@property (nonatomic, copy) NSString *resource_type_ext;

@end

@interface GKWYResultVideoInfoModel : NSObject

@property (nonatomic, strong) NSArray<GKWYResultVideoModel *> *video_list;
@property (nonatomic, assign) NSInteger total;

@end

@interface GKWYResultVideoModel : NSObject

@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *mv_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSString *thumbnail2;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *all_artist_id;
@property (nonatomic, copy) NSString *ting_uid;

@end
