//
//  GKWYJXArtistViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/10/11.
//  Copyright © 2018 gaokun. All rights reserved.
//

#import "GKWYJXArtistViewController.h"
#import "GKWYArtistModel.h"
#import "FXBlurView.h"

#import "GKWYArtistMainTableView.h"

#import "GKPageController.h"
#import "GKWYArtistSongListViewController.h"
#import "GKWYArtistAlbumListViewController.h"
#import "GKWYArtistVideoListViewController.h"
#import "GKWYArtistIntroViewController.h"
#import "JXCategoryView.h"

@interface GKWYJXArtistViewController ()<UITableViewDataSource, UITableViewDelegate, JXCategoryViewDelegate>

@property (nonatomic, strong) GKWYArtistMainTableView   *mainTableView;

@property (nonatomic, strong) UIView                    *lineView;

@property (nonatomic, strong) UIView                    *pageView;
@property (nonatomic, strong) JXCategoryTitleView       *categoryView;
@property (nonatomic, strong) UIScrollView              *mainScrollView;

@property (nonatomic, strong) UIView                    *headerView;
@property (nonatomic, strong) UIImageView               *topImgView;

@property (nonatomic, strong) GKWYArtistModel   *artistModel;

@property (nonatomic, strong) UIVisualEffectView *effectView;

@property (nonatomic, strong) NSArray                   *titles;
@property (nonatomic, strong) NSArray                   *childVCs;

// 数据是否请求成功
@property (nonatomic, assign) BOOL                      isRequest;
// mainTableView是否能滑动
@property (nonatomic, assign) BOOL                      isCanScroll;
// 是否到达临界点
@property (nonatomic, assign) BOOL                      isCriticalPoint;

@property (nonatomic, assign) NSInteger                 lastIndex;

@end

@implementation GKWYJXArtistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBackgroundColor = [UIColor clearColor];
    
    self.isCanScroll = YES;
    
    [self.view addSubview:self.mainTableView];
    [self.mainTableView addSubview:self.headerView];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self getArtistInfo];
    
    // 添加通知监听
    // 子视图离开临界点的通知
    [kNotificationCenter addObserver:self selector:@selector(leaveCritical:) name:@"LeaveCriticalPoint" object:nil];
    // 子视图水平滑动的通知
    [kNotificationCenter addObserver:self selector:@selector(horizontalScroll:) name:@"HorizontalScroll" object:nil];
}

- (void)dealloc {
    [kNotificationCenter removeObserver:self];
}

- (void)getArtistInfo {
    NSString *api = [NSString stringWithFormat:@"baidu.ting.artist.getinfo&tinguid=%@&artistid=%@", self.tinguid, self.artistid];
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        self.isRequest = YES;
        
        self.artistModel = [GKWYArtistModel yy_modelWithDictionary:responseObject];
        
        self.gk_navigationItem.title = self.artistModel.name;
        
        [self.topImgView sd_setImageWithURL:[NSURL URLWithString:self.artistModel.avatar_s500]
                           placeholderImage:[UIImage imageNamed:@"cm2_default_artist_banner"]];
        
        // 刷新tableview
        [self.mainTableView reloadData];
        
        // 刷新第一个
        [self scrollViewDidEndDecelerating:self.mainScrollView];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - Notification

- (void)leaveCritical:(NSNotification *)notify {
    BOOL canScroll = [notify.object[@"canScroll"] boolValue];
    
    if (canScroll) {
        self.isCanScroll = YES;
    }
}

- (void)horizontalScroll:(NSNotification *)notify {
    BOOL canScroll = [notify.object[@"canScroll"] boolValue];
    
    self.mainTableView.scrollEnabled = canScroll;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.mainTableView) return;
    // 当前偏移量
    CGFloat offsetY = scrollView.contentOffset.y;
    // 临界点
    CGFloat criticalPoint = [self.mainTableView rectForSection:0].origin.y - NAVBAR_HEIGHT;
    
    if (offsetY > 0) {
        scrollView.bounces = NO;
    }else {
        scrollView.bounces = YES;
    }
    
    // 蒙层渐变
    CGFloat alpha = 0;
    if (offsetY <= 80 - kArtistHeaderHeight) {
        alpha = 0;
    }else if (offsetY >= -NAVBAR_HEIGHT) {
        alpha = 1;
    }else {
        // 从 80 - kArtistHeaderHeight 到 -NAVBAR_HEIGHT
        alpha = 1 - ((-NAVBAR_HEIGHT - offsetY) / (kArtistHeaderHeight - NAVBAR_HEIGHT - 80));
    }
    
    self.effectView.hidden = alpha == 0;
    self.effectView.alpha = alpha;
    
    // 利用contentOffset处理内外层tableView的滑动冲突
    // 滑动到达临界点时固定mainTableView的位置
    if (offsetY >= criticalPoint) {
        scrollView.contentOffset = CGPointMake(0, criticalPoint);
        self.isCriticalPoint = YES;
    }else {
        self.isCriticalPoint = NO;
    }
    
    if (self.isCriticalPoint) {
        [kNotificationCenter postNotificationName:@"EnterCriticalPoint" object:@{@"canScroll": @1}];
        self.isCanScroll = NO;
    }else {
        if (!self.isCanScroll) {
            self.mainTableView.contentOffset = CGPointMake(0, criticalPoint);
        }
    }
    
    // headerView下拉放大
    if(offsetY <= -kArtistHeaderHeight) {
        CGRect f = self.headerView.frame;
        //上下放大
        f.origin.y      = offsetY;
        f.size.height   = -offsetY;
        //左右放大
        f.origin.x = (offsetY * KScreenW / kArtistHeaderHeight + KScreenW)/2;
        f.size.width = -offsetY * KScreenW / kArtistHeaderHeight;
        //改变头部视图的frame
        self.headerView.frame = f;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.mainScrollView) {
        NSInteger index = self.categoryView.selectedIndex;
        
        GKWYBaseSubViewController *currentVC = self.childVCs[index];
        
        [currentVC loadData];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isRequest ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:self.pageView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return KScreenH - NAVBAR_HEIGHT;
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didClickSelectedItemAtIndex:(NSInteger)index {
    GKWYBaseSubViewController *currentVC = self.childVCs[index];
    [currentVC loadData];
}

- (void)categoryView:(JXCategoryBaseView *)categoryView didScrollSelectedItemAtIndex:(NSInteger)index {
    GKWYBaseSubViewController *currentVC = self.childVCs[index];
    [currentVC loadData];
}

#pragma mark - 懒加载
- (GKWYArtistMainTableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[GKWYArtistMainTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _mainTableView.dataSource   = self;
        _mainTableView.delegate     = self;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.showsVerticalScrollIndicator = NO;
        _mainTableView.contentInset = UIEdgeInsetsMake(kArtistHeaderHeight, 0, 0, 0);
    }
    return _mainTableView;
}

- (UIView *)headerView {
    if (!_headerView) {
        UIView *headerView = [UIView new];
        headerView.frame = CGRectMake(0, 0, KScreenW, kArtistHeaderHeight);
        
        [headerView addSubview:self.topImgView];
        [headerView addSubview:self.effectView];
        
        [self.topImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(headerView);
        }];
        
        [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(headerView);
        }];
        
        _headerView = headerView;
    }
    return _headerView;
}

- (UIImageView *)topImgView {
    if (!_topImgView) {
        _topImgView                 = [UIImageView new];
        _topImgView.contentMode     = UIViewContentModeScaleAspectFill;
        _topImgView.frame           = CGRectMake(0, 0, KScreenW, kArtistHeaderHeight);
        _topImgView.clipsToBounds   = YES;
        _topImgView.image           = [UIImage imageNamed:@"cm2_default_artist_banner"];
    }
    return _topImgView;
}

- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _effectView.alpha = 0;
    }
    return _effectView;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"热门", @"专辑", @"视频", @"歌手信息"];
    }
    return _titles;
}

- (NSArray *)childVCs {
    if (!_childVCs) {
        GKWYArtistSongListViewController *songVC = [GKWYArtistSongListViewController new];
        songVC.model = self.artistModel;
        
        GKWYArtistAlbumListViewController *albumVC = [GKWYArtistAlbumListViewController new];
        albumVC.model = self.artistModel;
        
        GKWYArtistVideoListViewController *videoVC = [GKWYArtistVideoListViewController new];
        videoVC.model = self.artistModel;
        
        GKWYArtistIntroViewController *introVC = [GKWYArtistIntroViewController new];
        introVC.model = self.artistModel;
        
        _childVCs = @[songVC, albumVC, videoVC, introVC];
    }
    return _childVCs;
}

- (UIView *)pageView {
    if (!_pageView) {
        _pageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH - NAVBAR_HEIGHT)];
        _pageView.backgroundColor = [UIColor clearColor];
        
        [_pageView addSubview:self.categoryView];
        
        [_pageView addSubview:self.mainScrollView];
    }
    return _pageView;
}

- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, KScreenW, kArtistSegmentHeight)];
        _categoryView.titles = self.titles;
        _categoryView.backgroundColor = [UIColor whiteColor];
        _categoryView.delegate = self;
        _categoryView.titleSelectedColor = kAPPDefaultColor;
        _categoryView.titleColor = [UIColor blackColor];
        _categoryView.titleFont = [UIFont systemFontOfSize:16.0f];
        _categoryView.titleSelectedFont = [UIFont boldSystemFontOfSize:16.0f];
        _categoryView.cellChangeInHalf = YES;
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorLineViewColor = kAPPDefaultColor;
        lineView.indicatorLineWidth = kAdaptive(60.0f);
        lineView.lineStyle = JXCategoryIndicatorLineStyle_IQIYI;
        _categoryView.indicators = @[lineView];
        
        _categoryView.contentScrollView = self.mainScrollView;
        
        UIView *btmLineView = [UIView new];
        btmLineView.backgroundColor = kAppLineColor;
        btmLineView.frame = CGRectMake(0, kArtistSegmentHeight - 0.5, KScreenW, 0.5);
        [_categoryView addSubview:btmLineView];
    }
    return _categoryView;
}

- (UIScrollView *)mainScrollView {
    if (!_mainScrollView) {
        CGFloat scrollW = KScreenW;
        CGFloat scrollH = KScreenH - NAVBAR_HEIGHT - kArtistSegmentHeight;
        
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kArtistSegmentHeight, scrollW, scrollH)];
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.bounces = NO;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.delegate = self;
        
        for (NSInteger i = 0; i < self.childVCs.count; i++) {
            UIViewController *vc = self.childVCs[i];
            
            [self addChildViewController:vc];
            [_mainScrollView addSubview:vc.view];
            
            vc.view.frame = CGRectMake(i * scrollW, 0, scrollW, scrollH);
        }
        _mainScrollView.contentSize = CGSizeMake(scrollW * self.childVCs.count, 0);
    }
    return _mainScrollView;
}

@end
