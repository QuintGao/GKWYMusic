//
//  GKWYRoutes.h
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/5.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import <JLRoutes/JLRoutes.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKWYRoutes : JLRoutes

+ (void)registerRoutes;

+ (BOOL)routeWithUrlString:(NSString *)urlString;

+ (BOOL)routeWithUrlString:(NSString *)urlString params:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
