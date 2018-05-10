//
//  GKWYPageViewController.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/23.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYBaseViewController.h"
#import "GKPageController.h"

@interface GKWYPageViewController : GKWYBaseViewController

@property (nonatomic, strong) GKPageController  *pageVC;

@property (nonatomic, strong) NSArray           *childVCs;
@property (nonatomic, strong) NSArray           *titles;

- (void)reloadData;

@end
