//
//  GKWYPageViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/23.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYPageViewController.h"

@interface GKWYPageViewController ()<WMPageControllerDataSource>

@end

@implementation GKWYPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addChildViewController:self.pageVC];
    [self.view addSubview:self.pageVC.view];
    
    [self.pageVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self hideNavLine];
}

- (void)reloadData {
    [self.pageVC reloadData];
    
    self.pageVC.menuView.backgroundColor = kAPPDefaultColor;
}

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.childVCs.count;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    return self.childVCs[index];
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return self.titles[index];
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    CGFloat leftMargin  = 0;
    CGFloat originY     = 0;
    return CGRectMake(leftMargin, originY, self.view.frame.size.width - 2 * leftMargin, 36.0f);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat originY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:pageController.menuView]);
    return CGRectMake(0, originY, self.view.frame.size.width, self.view.frame.size.height - originY - self.gk_navigationBar.gk_height);
}

#pragma mark - 懒加载
- (GKPageController *)pageVC {
    if (!_pageVC) {
        _pageVC                             = [[GKPageController alloc] init];
        _pageVC.view.backgroundColor        = [UIColor whiteColor];
        _pageVC.menuViewStyle               = WMMenuViewStyleLine;
        _pageVC.pageAnimatable              = YES;
        _pageVC.postNotification            = YES;
        _pageVC.bounces                     = YES;
        _pageVC.automaticallyCalculatesItemWidths = YES; // 自动根据字符串计算item宽度
        
        _pageVC.titleSizeNormal             = 14.0f;
        _pageVC.titleSizeSelected           = 15.0f;
        _pageVC.titleColorNormal            = [UIColor whiteColor];
        _pageVC.titleColorSelected          = [UIColor whiteColor];
        _pageVC.progressWidth               = 30.0f;
        _pageVC.progressHeight              = 2.0f;
        _pageVC.progressColor               = [UIColor whiteColor];
        _pageVC.progressViewBottomSpace     = 2.0f;
        _pageVC.dataSource                  = self;
    }
    return _pageVC;
}

@end
