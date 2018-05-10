//
//  GKHttpManager.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKHttpManager.h"

//#define kBaseUrl @"http://music.baidu.com/"
#define kBaseUrl @"http://tingapi.ting.baidu.com/v1/restserver/ting?format=json&calback=&from=webapp_music&method="

@interface GKHttpManager()

@end

@implementation GKHttpManager

+ (instancetype)sharedInstance {
    static GKHttpManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [GKHttpManager new];
    });
    return manager;
}

- (void)get:(NSString *)api params:(NSDictionary *)params successBlock:(successBlock)successBlock failureBlock:(failureBlock)failureBlock {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *url = [kBaseUrl stringByAppendingString:api];
    
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureBlock(error);
    }];
}

- (void)getWithURL:(NSString *)url params:(NSDictionary *)params successBlock:(successBlock)successBlock failureBlock:(failureBlock)failureBlock {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"application/x-javascript", @"application/javascript", nil]];
    
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        
        successBlock(dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureBlock(error);
    }];
}

@end
