//
//  GKWYWidgetRoutes.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/12.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYWidgetRoutes.h"
#import "GKWYSongListViewController.h"
#import "GKWYListViewController.h"

NSString *const GKWYWidgetRoutesScheme = @"GKWYWidget";

@implementation GKWYWidgetRoutes

+ (instancetype)globalRoutes {
    return [self routesForScheme:GKWYWidgetRoutesScheme];
}

+ (void)registerRoutes {
    GKWYWidgetRoutes *routes = [self globalRoutes];
    
    // 歌曲推荐
    [routes addRoute:@"music" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        return [self handleMusicRouteWithParams:parameters];
    }];
    
    // 歌单推荐
    [routes addRoute:@"playlist" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        return [self handlePlaylistRouteWithParams:parameters];
    }];
    
    // 雷达
    [routes addRoute:@"radar" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        return [self handleRadarRouteWithParams:parameters];
    }];
    
    // 私人FM
    [routes addRoute:@"fm" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        return [self handleFMRouteWithParams:parameters];
    }];
    
    // 我喜欢的音乐
    [routes addRoute:@"liked" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        return [self handleLikedRouteWithParams:parameters];
    }];
}

+ (BOOL)routeWithUrlString:(NSString *)urlString {
    return [self routeURL:[NSURL URLWithString:urlString]];
}

+ (UINavigationController *)topNavigationController {
    return GKConfigure.visibleViewController.navigationController;
}

#pragma mark - Handle
+ (BOOL)handleMusicRouteWithParams:(NSDictionary *)params {
    GKWYSongListViewController *listVC = [[GKWYSongListViewController alloc] init];
    [[self topNavigationController] pushViewController:listVC animated:YES];
    return YES;
}

+ (BOOL)handlePlaylistRouteWithParams:(NSDictionary *)params {
    GKWYListViewController *listVC = [[GKWYListViewController alloc] initWithType:GKWYListType_CollectionView];
    listVC.isRecommend = YES;
    [[self topNavigationController] pushViewController:listVC animated:YES];
    return YES;
}

+ (BOOL)handleRadarRouteWithParams:(NSDictionary *)params {
    return YES;
}

+ (BOOL)handleFMRouteWithParams:(NSDictionary *)params {
    return YES;
}

+ (BOOL)handleLikedRouteWithParams:(NSDictionary *)params {
    return YES;
}

@end
