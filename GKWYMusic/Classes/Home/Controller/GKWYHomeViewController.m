//
//  GKWYHomeViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/19.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYHomeViewController.h"
#import "GKWYListViewController.h"
#import "GKWYSearchViewController.h"
#import "GKSearchBar.h"

@interface GKWYHomeViewController ()<GKSearchBarDelegate>

@property (nonatomic, strong) GKSearchBar *searchBar;

@end

@implementation GKWYHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.gk_navigationBar addSubview:self.searchBar];
    
    NSArray *data = @[@{@"title": @"新歌", @"type": @1},
                      @{@"title": @"热歌", @"type": @2},
                      @{@"title": @"摇滚", @"type": @11},
                      @{@"title": @"爵士", @"type": @12},
                      @{@"title": @"流行", @"type": @16},
                      @{@"title": @"欧美金曲", @"type": @21},
                      @{@"title": @"经典老歌", @"type": @22},
                      @{@"title": @"情歌对唱", @"type": @23},
                      @{@"title": @"影视金曲", @"type": @24},
                      @{@"title": @"网络歌曲", @"type": @25}];
    
    NSMutableArray *titles   = [NSMutableArray new];
    NSMutableArray *childVCs = [NSMutableArray new];
    
    [data enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [titles addObject:obj[@"title"]];
        
        GKWYListViewController *listVC = [GKWYListViewController new];
        listVC.type = [obj[@"type"] integerValue];
        
        [childVCs addObject:listVC];
    }];
    
    self.childVCs = childVCs;
    self.titles   = titles;
    
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *lastPlayId = [GKWYMusicTool lastMusicId];
    
    [self.searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gk_navigationBar).offset(15.0f);
        make.right.equalTo(self.gk_navigationBar).offset(lastPlayId ? -52.0f : -15.0f);
        make.centerY.equalTo(self.gk_navigationBar.mas_bottom).offset(-44.0f);
        make.height.mas_equalTo(44.0f);
    }];
    [self.searchBar layoutIfNeeded];
}

#pragma mark - EVNCustomSearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(GKSearchBar *)searchBar {
    GKWYSearchViewController *searchVC = [GKWYSearchViewController new];
    [self.navigationController pushViewController:searchVC animated:YES];
    
    return NO;
}

#pragma mark - 懒加载
- (GKSearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar              = [[GKSearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH)];
        _searchBar.placeholder  = @"搜索";
        _searchBar.iconAlign    = GKSearchBarIconAlignCenter;
        _searchBar.iconImage    = [UIImage imageNamed:@"cm2_topbar_icn_search"];
        _searchBar.delegate     = self;
        
        if (@available(iOS 11.0, *)) {
            [_searchBar.heightAnchor constraintLessThanOrEqualToConstant:44].active = YES;
        }
    }
    return _searchBar;
}

@end
