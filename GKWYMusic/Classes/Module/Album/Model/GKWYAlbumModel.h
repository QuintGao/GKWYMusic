//
//  GKWYAlbumModel.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/11.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKWYArtistModel.h"

@interface GKWYAlbumModel : NSObject

@property (nonatomic, copy) NSString *album_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *subType;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *picUrl;
@property (nonatomic, copy) NSString *blurPicUrl;
@property (nonatomic, copy) NSString *publishTime;
@property (nonatomic, strong) NSArray *alias; // 专辑别名
@property (nonatomic, copy) NSString *size;

@property (nonatomic, strong) GKWYArtistModel *artist;

@property (nonatomic, strong) NSArray<GKWYArtistModel *> *artists;

@property (nonatomic, copy) NSString *collectCount;
@property (nonatomic, copy) NSString *commentCount;
@property (nonatomic, copy) NSString *shareCount;

@property (nonatomic, strong) NSAttributedString *nameAttr;

@property (nonatomic, copy) NSString *artistStr;
@property (nonatomic, strong) NSAttributedString *artistAttr;
@property (nonatomic, copy) NSString *publishTimeStr;

@property (nonatomic, strong) NSAttributedString *artistsAttr;
@property (nonatomic, copy) NSString *keyword;

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, copy) NSString *route_url;

@end
