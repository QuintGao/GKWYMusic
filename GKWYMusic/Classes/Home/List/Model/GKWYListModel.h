//
//  GKWYListModel.h
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/21.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKWYListModel : NSObject

@property (nonatomic, copy) NSString *list_id;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *coverImgUrl;

@property (nonatomic, copy) NSString *playCount;
@property (nonatomic, copy) NSString *formatPlayCount;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *subscribedCount;
@property (nonatomic, copy) NSString *commentCount;
@property (nonatomic, copy) NSString *shareCount;

@end

NS_ASSUME_NONNULL_END
