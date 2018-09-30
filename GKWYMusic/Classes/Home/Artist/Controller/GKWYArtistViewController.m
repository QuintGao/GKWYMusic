//
//  GKWYArtistViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/15.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYArtistViewController.h"
#import "GKWYArtistModel.h"
#import "FXBlurView.h"

#import "GKWYArtistMainTableView.h"

#import "GKPageController.h"
#import "GKWYArtistSongListViewController.h"
#import "GKWYArtistAlbumListViewController.h"
#import "GKWYArtistVideoListViewController.h"
#import "GKWYArtistIntroViewController.h"

@interface GKWYArtistViewController ()<UITableViewDataSource, UITableViewDelegate, WMPageControllerDataSource, WMPageControllerDelegate>

@property (nonatomic, strong) GKWYArtistMainTableView   *mainTableView;

@property (nonatomic, strong) UIView                    *lineView;
@property (nonatomic, strong) GKPageController          *pageVC;
@property (nonatomic, strong) UIView                    *pageView;

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

@implementation GKWYArtistViewController

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
        [self.pageVC reloadData];
        
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

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.childVCs.count;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return self.titles[index];
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    return self.childVCs[index];
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    // 设置menuView的frame
    return CGRectMake(0, 0, KScreenW, kArtistSegmentHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    // 设置contentView的frame
    CGFloat maxY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:pageController.menuView]);
    return CGRectMake(0, maxY, KScreenW, KScreenH - maxY - NAVBAR_HEIGHT);
}

#pragma mark - WMPageControllerDelegate
- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
    WMMenuItem *lastItem = [pageController.menuView itemAtIndex:self.lastIndex];
    lastItem.font = [UIFont systemFontOfSize:16.0f];
    
    NSInteger index = [info[@"index"] integerValue];
    self.lastIndex = index;
    WMMenuItem *item = [pageController.menuView itemAtIndex:index];
    item.font = [UIFont boldSystemFontOfSize:16.0f];
    
    GKWYBaseSubViewController *vc = (GKWYBaseSubViewController *)viewController;
    
    if (self.artistModel) {
        [vc loadData];
    }
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
        [self addChildViewController:self.pageVC];
        [self.pageVC didMoveToParentViewController:self];
        
        _pageView = self.pageVC.view;
    }
    return _pageView;
}

- (GKPageController *)pageVC {
    if (!_pageVC) {
        _pageVC                             = [GKPageController new];
        _pageVC.dataSource                  = self;
        _pageVC.delegate                    = self;
        
        // 菜单属性
        _pageVC.menuItemWidth               = KScreenW / 4.0f;
        _pageVC.menuViewStyle               = WMMenuViewStyleLine;
        
        // 菜单文字属性
        _pageVC.titleSizeNormal             = 16.0f;
        _pageVC.titleSizeSelected           = 16.0f;
        _pageVC.titleColorNormal            = [UIColor blackColor];
        _pageVC.titleColorSelected          = kAPPDefaultColor;
        
        // 进度条属性
        _pageVC.progressColor               = kAPPDefaultColor;
        _pageVC.progressWidth               = kAdaptive(60.0f);
        _pageVC.progressHeight              = 3.0f;
        _pageVC.progressViewBottomSpace     = kAdaptive(10.0f);
        _pageVC.progressViewCornerRadius    = _pageVC.progressHeight / 2;
        
        // 调皮效果
        _pageVC.progressViewIsNaughty       = YES;
    }
    return _pageVC;
}

@end
