//
//  GKHttpManager.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHttpManager [GKHttpManager sharedInstance]

typedef void(^successBlock)(id responseObject);
typedef void(^failureBlock)(NSError *error);

@interface GKHttpManager : NSObject

+ (instancetype)sharedInstance;

- (void)get:(NSString *)api params:(NSDictionary *)params successBlock:(successBlock)successBlock failureBlock:(failureBlock)failureBlock;

- (void)getWithURL:(NSString *)url params:(NSDictionary *)params successBlock:(successBlock)successBlock failureBlock:(failureBlock)failureBlock;

@end
