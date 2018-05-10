//
//  GKWYResultModel.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/3.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GKWYArtistModel, GKWYSongModel, GKWYAlbumModel;

@interface GKWYResultModel : NSObject

@property (nonatomic, strong) NSArray <GKWYArtistModel *> *artist;
@property (nonatomic, strong) NSArray <GKWYSongModel *> *song;
@property (nonatomic, strong) NSArray <GKWYAlbumModel *> *album;

@end

@interface GKWYArtistModel : NSObject

@property (nonatomic, copy) NSString *artistid;
@property (nonatomic, copy) NSString *artistname;
@property (nonatomic, copy) NSString *artistpic;
@property (nonatomic, copy) NSString *weight;

@end

@interface GKWYSongModel : NSObject

@property (nonatomic, copy) NSString *songid;
@property (nonatomic, copy) NSString *songname;
@property (nonatomic, copy) NSString *artistname;
@property (nonatomic, copy) NSString *has_mv;

@end

@interface GKWYAlbumModel : NSObject

@property (nonatomic, copy) NSString *albumid;
@property (nonatomic, copy) NSString *albumname;
@property (nonatomic, copy) NSString *artistname;
@property (nonatomic, copy) NSString *artistpic;

@end
