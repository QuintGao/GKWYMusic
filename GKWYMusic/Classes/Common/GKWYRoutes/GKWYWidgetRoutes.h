//
//  GKWYWidgetRoutes.h
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/12.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import <JLRoutes/JLRoutes.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKWYWidgetRoutes : JLRoutes

+ (void)registerRoutes;

+ (BOOL)routeWithUrlString:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
