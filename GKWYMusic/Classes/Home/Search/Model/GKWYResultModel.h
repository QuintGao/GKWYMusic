//
//  GKWYResultModel.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/3.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GKWYResultArtistInfoModel, GKWYResultArtistModel;
@class GKWYResultSongInfoModel, GKWYMusicModel;
@class GKWYResultAlbumInfoModel, GKWYResultAlbumModel;
@class GKWYResultVideoInfoModel, GKWYResultVideoModel;
@class GKWYResultPlayListInfoModel, GKWYResultPlayListModel, GKWYResultPlayListUserInfoModel;
@class GKWYResultUserInfoModel, GKWYResultUserModel;

#pragma mark - 搜索结果
@interface GKWYResultModel : NSObject

@property (nonatomic, strong) GKWYResultArtistInfoModel     *artist_info;
@property (nonatomic, strong) GKWYResultSongInfoModel       *song_info;
@property (nonatomic, strong) GKWYResultAlbumInfoModel      *album_info;
@property (nonatomic, strong) GKWYResultVideoInfoModel      *video_info;
@property (nonatomic, strong) GKWYResultPlayListInfoModel   *playlist_info;
@property (nonatomic, strong) GKWYResultUserInfoModel       *user_info;

@end

#pragma mark - 歌手
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

#pragma mark - 单曲
@interface GKWYResultSongInfoModel : NSObject

@property (nonatomic, strong) NSArray<GKWYMusicModel *> *song_list;
@property (nonatomic, assign) NSInteger total;

@end

#pragma mark - 专辑
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


#pragma mark - 视频
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

#pragma mark - 歌单
@interface GKWYResultPlayListInfoModel : NSObject

@property (nonatomic, strong) NSArray<GKWYResultPlayListModel *> *play_list;
@property (nonatomic, assign) NSInteger total;

@end

@interface GKWYResultPlayListModel : NSObject

@property (nonatomic, copy) NSString    *firstSongid;
@property (nonatomic, copy) NSString    *diy_id;
@property (nonatomic, copy) NSString    *diy_pic;
@property (nonatomic, copy) NSString    *song_num;
@property (nonatomic, copy) NSString    *diy_tag;
@property (nonatomic, copy) NSString    *user_id;
@property (nonatomic, strong) GKWYResultPlayListUserInfoModel   *userinfo;
@property (nonatomic, copy) NSString    *diy_title;
@property (nonatomic, copy) NSString    *listen_num;

@end

@interface GKWYResultPlayListUserInfoModel : NSObject

@property (nonatomic, copy) NSString    *userpic;
@property (nonatomic, copy) NSString    *flag;
@property (nonatomic, copy) NSString    *userpic_small;
@property (nonatomic, copy) NSString    *userid;
@property (nonatomic, copy) NSString    *username;

@end

#pragma mark - 用户
@interface GKWYResultUserInfoModel : NSObject

@property (nonatomic, strong) NSArray<GKWYResultUserModel *> *user_list;
@property (nonatomic, assign) NSInteger total;

@end

@interface GKWYResultUserModel : NSObject

@property (nonatomic, copy) NSString    *level;
@property (nonatomic, copy) NSString    *userpic;
@property (nonatomic, copy) NSString    *flag;
@property (nonatomic, copy) NSString    *renzheng_info;
@property (nonatomic, copy) NSString    *follow_num;
@property (nonatomic, copy) NSString    *friend_num;
@property (nonatomic, copy) NSString    *dynamic_num;
@property (nonatomic, copy) NSString    *desc;
@property (nonatomic, copy) NSString    *isFriend;
@property (nonatomic, copy) NSString    *province;
@property (nonatomic, copy) NSString    *sex;
@property (nonatomic, copy) NSString    *tag;
@property (nonatomic, copy) NSString    *username;
@property (nonatomic, copy) NSString    *userid;
@property (nonatomic, copy) NSString    *bth_info;

@end
