//
//  GKPageController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/23.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKPageController.h"

@interface GKPageController ()

@end

@implementation GKPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - WMMenuViewDelegate
- (CGFloat)menuView:(WMMenuView *)menu widthForItemAtIndex:(NSInteger)index {
    return [super menuView:menu widthForItemAtIndex:index] + 20.0f;
}

@end
