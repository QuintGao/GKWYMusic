//
//  GKWYSearchResultViewController.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/1.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYSearchResultViewController.h"
#import "GKSearchBar.h"
#import "GKWYResultListViewController.h"
#import "GKWYResultAllViewController.h"

@interface GKWYSearchResultViewController()<GKSearchBarDelegate, JXCategoryTitleViewDataSource>

@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) GKSearchBar *searchBar;

@property (nonatomic, strong) NSArray *titles;

@end

@implementation GKWYSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_backImage = nil;
    self.gk_backStyle = GKNavigationBarBackStyleNone;
    self.gk_navLeftBarButtonItem = nil;
    self.gk_navLineHidden = YES;
    self.gk_navItemLeftSpace = 0;
    [self.gk_navigationBar addSubview:self.searchView];
    
    self.searchBar.text = self.keyword;
    
    //    // 默认1 即单曲 , 取值意义 : 1: 单曲, 10: 专辑, 100: 歌手, 1000: 歌单, 1002: 用户, 1004: MV, 1006: 歌词, 1009: 电台, 1014: 视频, 1018:综合,
    
    self.titles = @[@{@"type": @"1018", @"title": @"综合"},
                    @{@"type": @"1", @"title": @"单曲"},
                    @{@"type": @"1000", @"title": @"歌单"},
                    @{@"type": @"1014", @"title": @"视频"},
                    @{@"type": @"100", @"title": @"歌手"},
                    @{@"type": @"10", @"title": @"专辑"}];
    [self reloadData];
}

- (void)initializeViews {
    self.categoryView.titleDataSource = self;
    
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.indicatorColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
    lineView.lineStyle = JXCategoryIndicatorLineStyle_Lengthen;
    lineView.indicatorWidthIncrement = 8;
    lineView.indicatorHeight = kAdaptive(10.0);
    lineView.verticalMargin = kAdaptive(18.0);
    self.indicatorView = lineView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GKWYMusicTool hidePlayBtn];
}

#pragma mark - JXCategoryTitleViewDataSource
- (NSInteger)numberOfTitleView:(JXCategoryTitleView *)titleView {
    return self.titles.count;
}

- (NSString *)titleView:(JXCategoryTitleView *)titleView titleForIndex:(NSInteger)index {
    return [self.titles[index] objectForKey:@"title"];
}

#pragma mark - JXCategoryListContainerViewDelegate
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    if (index == 0) {
        GKWYResultAllViewController *listVC = [[GKWYResultAllViewController alloc] init];
        listVC.pageVC = self;
        listVC.type = [[self.titles[index] objectForKey:@"type"] integerValue];
        listVC.keyword = self.keyword;
        return listVC;
    }else {
        GKWYResultListViewController *listVC = [[GKWYResultListViewController alloc] initWithType:GKWYListType_TableView];
        listVC.pageVC = self;
        listVC.type = [[self.titles[index] objectForKey:@"type"] integerValue];
        listVC.keyword = self.keyword;
        return listVC;
    }
}

#pragma mark - 懒加载
- (UIView *)searchView {
    if (!_searchView) {
        _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 44)];
        
        UIButton *backBtn = [[UIButton alloc] init];
        backBtn.frame = CGRectMake(0, 0, 44, 44);
        [backBtn setImage:[UIImage imageNamed:@"cm2_topbar_icn_back"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backItemClick:) forControlEvents:UIControlEventTouchUpInside];
        [_searchView addSubview:backBtn];
        [_searchView addSubview:self.searchBar];
    }
    return _searchView;
}

- (GKSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar              = [[GKSearchBar alloc] initWithFrame:CGRectMake(40, 0, KScreenW - 40, 44)];
        _searchBar.placeholderColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
        _searchBar.iconImage    = [[UIImage imageNamed:@"cm2_topbar_icn_search"] changeImageWithColor:UIColor.whiteColor];
        _searchBar.iconAlign    = GKSearchBarIconAlignLeft;
        _searchBar.delegate     = self;
        _searchBar.textField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        _searchBar.textField.layer.cornerRadius = _searchBar.textField.frame.size.height / 2;
        _searchBar.textField.textColor = UIColor.whiteColor;
        
        if (@available(iOS 11.0, *)) {
            [_searchBar.heightAnchor constraintLessThanOrEqualToConstant:44].active = YES;
        }
    }
    return _searchBar;
}

@end
