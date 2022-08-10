//
//  GKWYPlayListModel.h
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/21.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKWYPlayListCreator : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *userType;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, assign) NSInteger authStatus;

@end

@interface GKWYPlayListModel : NSObject

@property (nonatomic, copy) NSString *list_id;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *coverImgUrl;

@property (nonatomic, strong) GKWYPlayListCreator *creator;

@property (nonatomic, copy) NSString *playCount;
@property (nonatomic, copy) NSString *formatPlayCount;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *subscribedCount;
@property (nonatomic, copy) NSString *commentCount;
@property (nonatomic, copy) NSString *shareCount;
@property (nonatomic, copy) NSString *trackCount;

@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, strong) NSAttributedString *nameAttr;
@property (nonatomic, copy) NSString *content;


@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, copy) NSString *route_url;

@end

NS_ASSUME_NONNULL_END
