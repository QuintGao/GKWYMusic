//
//  GKWYVideoDetailModel.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/29.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GKWYVideoInfo, GKWYVideoFiles, GKWYVideoMVInfo, GKWYVideoArtist;

@interface GKWYVideoDetailModel : NSObject

@property (nonatomic, strong) GKWYVideoInfo *video_info;

@property (nonatomic, strong) NSDictionary *files;
@property (nonatomic, strong) GKWYVideoFiles *video_file;

@property (nonatomic, copy) NSString *min_definition;

@property (nonatomic, copy) NSString *max_definition;

@property (nonatomic, strong) GKWYVideoMVInfo *mv_info;

@property (nonatomic, copy) NSString *share_url;

@property (nonatomic, copy) NSString *share_pic;

@property (nonatomic, copy) NSString *video_type;

@end

@interface GKWYVideoInfo : NSObject

@property (nonatomic, copy) NSString *video_id;
@property (nonatomic, copy) NSString *mv_id;
@property (nonatomic, copy) NSString *provider;
@property (nonatomic, copy) NSString *sourcepath;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSString *thumbnail2;
@property (nonatomic, copy) NSString *del_status;
@property (nonatomic, copy) NSString *distribution;
@property (nonatomic, copy) NSString *tvid;

@end

@interface GKWYVideoFiles : NSObject

@property (nonatomic, copy) NSString *video_file_id;
@property (nonatomic, copy) NSString *video_id;
@property (nonatomic, copy) NSString *definition;
@property (nonatomic, copy) NSString *file_link;
@property (nonatomic, copy) NSString *file_format;
@property (nonatomic, copy) NSString *file_extension;
@property (nonatomic, copy) NSString *file_duration;
@property (nonatomic, copy) NSString *file_size;
@property (nonatomic, copy) NSString *source_path;
@property (nonatomic, copy) NSString *aspect_radio;
@property (nonatomic, copy) NSString *player_param;

@end

@interface GKWYVideoMVInfo : NSObject

@property (nonatomic, copy) NSString *mv_id;
@property (nonatomic, copy) NSString *all_artist_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *aliastitle;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *play_nums;
@property (nonatomic, copy) NSString *publishtime;
@property (nonatomic, copy) NSString *del_status;
@property (nonatomic, strong) NSArray<GKWYVideoArtist *> *artist_list;
@property (nonatomic, copy) NSString *artist_id;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSString *thumbnail2;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *provider;

@end

@interface GKWYVideoArtist : NSObject

@property (nonatomic, copy) NSString *artist_id;
@property (nonatomic, copy) NSString *ting_uid;
@property (nonatomic, copy) NSString *artist_name;
@property (nonatomic, copy) NSString *artist_480_800;
@property (nonatomic, copy) NSString *artist_640_1136;
@property (nonatomic, copy) NSString *artist_small;
@property (nonatomic, copy) NSString *artist_mini;
@property (nonatomic, copy) NSString *artist_s180;
@property (nonatomic, copy) NSString *artist_s300;
@property (nonatomic, copy) NSString *artist_s500;
@property (nonatomic, copy) NSString *del_status;

@end
