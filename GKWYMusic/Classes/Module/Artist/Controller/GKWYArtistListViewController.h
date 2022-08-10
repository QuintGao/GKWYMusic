//
//  GKWYArtistListViewController.h
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/5.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYBaseListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKWYArtistListViewController : GKWYBaseListViewController

- (instancetype)initWithIndex:(NSInteger)index;

@property (nonatomic, copy) NSString *artist_id;
@property (nonatomic, copy) NSString *artist_name;

@end

NS_ASSUME_NONNULL_END
