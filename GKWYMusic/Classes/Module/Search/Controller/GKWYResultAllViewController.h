//
//  GKWYResultAllViewController.h
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/2.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYBaseListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKWYResultAllViewController : GKWYBaseListViewController

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *keyword;

@end

NS_ASSUME_NONNULL_END
