//
//  GKWYRoutes.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/5.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYRoutes.h"
#import "GKWYAlbumViewController.h"
#import "GKWYArtistViewController.h"
#import "GKWYPlayListViewController.h"
#import "GKWYVideoViewController.h"

NSString *const GKWYRoutesScheme = @"gkwymusic";

@implementation GKWYRoutes

+ (instancetype)globalRoutes {
    return [GKWYRoutes routesForScheme:GKWYRoutesScheme];
}

+ (void)registerRoutes {
    GKWYRoutes *routes = [GKWYRoutes globalRoutes];
    
    [routes addRoute:@"song" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        return [self handleSongRoute:parameters];
    }];
    
    [routes addRoute:@"album" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        return [self handleAlbumRoute:parameters];
    }];
    
    [routes addRoute:@"artist" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        return [self handleArtistRoute:parameters];
    }];
    
    [routes addRoute:@"playlist" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        return [self handlePlayListRoute:parameters];
    }];
    
    [routes addRoute:@"video" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        return [self handleVideoRoute:parameters];
    }];
}

+ (BOOL)routeWithUrlString:(NSString *)urlString {
    return [GKWYRoutes routeURL:[NSURL URLWithString:urlString]];
}

+ (BOOL)routeWithUrlString:(NSString *)urlString params:(NSDictionary *)params {
    return [GKWYRoutes routeURL:[NSURL URLWithString:urlString] withParameters:params];
}

+ (UINavigationController *)topNavigationController {
    return GKConfigure.visibleViewController.navigationController;
}

#pragma mark - Private Methods
+ (BOOL)handleSongRoute:(NSDictionary *)params {
    NSArray *list = params[@"list"];
    NSInteger index = [params[@"index"] integerValue];
    
    [kWYPlayerVC setPlayerList:list];
    [kWYPlayerVC playMusicWithIndex:index isSetList:YES];
    [kWYPlayerVC show];
    
    return YES;
}

+ (BOOL)handleAlbumRoute:(NSDictionary *)params {
    GKWYAlbumViewController *albumVC = [[GKWYAlbumViewController alloc] init];
    albumVC.album_id = params[@"id"];
    [[self topNavigationController] pushViewController:albumVC animated:YES];
    return YES;
}

+ (BOOL)handleArtistRoute:(NSDictionary *)params {
    GKWYArtistViewController *artistVC = [[GKWYArtistViewController alloc] init];
    artistVC.artist_id = params[@"id"];
    artistVC.model = params[@"model"];
    [[self topNavigationController] pushViewController:artistVC animated:YES];
    return YES;
}

+ (BOOL)handlePlayListRoute:(NSDictionary *)params {
    GKWYPlayListViewController *vc = [[GKWYPlayListViewController alloc] init];
    vc.list_id = params[@"id"];
    [[self topNavigationController] pushViewController:vc animated:YES];
    return YES;
}

+ (BOOL)handleVideoRoute:(NSDictionary *)params {
    GKWYVideoViewController *videoVC = [[GKWYVideoViewController alloc] init];
    videoVC.mv_id = params[@"id"];
    videoVC.model = params[@"model"];
    [[self topNavigationController] pushViewController:videoVC animated:YES];
    return YES;
}

@end
