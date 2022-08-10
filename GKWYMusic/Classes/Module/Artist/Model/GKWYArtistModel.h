//
//  GKWYArtistModel.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/15.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GKWYArtistDescModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;

@property (nonatomic, assign) CGFloat cellHeight;

@end

@interface GKWYArtistModel : NSObject

@property (nonatomic, copy) NSString *artist_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *picUrl;
@property (nonatomic, copy) NSString *imglvlUrl;
@property (nonatomic, copy) NSString *briefDesc;
@property (nonatomic, strong) NSNumber *albumSize;
@property (nonatomic, strong) NSNumber *musicSize;
@property (nonatomic, strong) NSNumber *mvSize;

@property (nonatomic, strong) NSArray *identifyTag;

@property (nonatomic, copy) NSString *identify;

@property (nonatomic, strong) NSAttributedString *introAttr;

@property (nonatomic, assign) CGFloat           introHeight;
@property (nonatomic, assign) BOOL              hasMoreIntro;

@property (nonatomic, copy) NSString *route_url;

@end
