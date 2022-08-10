//
//  GKWYTagModel.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/24.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKWYTagModel.h"

@interface GKWYTagModel : NSObject

@property (nonatomic, copy) NSString *searchWord;
@property (nonatomic, copy) NSString *score;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *iconType;
@property (nonatomic, copy) NSString *iconUrl;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *alg;

@end
