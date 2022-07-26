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
#import "GKWYArtistSongListViewController.h"
#import "GKWYArtistAlbumListViewController.h"
#import "GKWYArtistVideoListViewController.h"
#import "GKWYArtistIntroViewController.h"
#import <GKPageScrollView/GKPageScrollView.h>
#import "GKWYArtistHeaderView.h"
#import <JXCategoryViewExt/JXCategoryView.h>

#define kCriticalPoint -ADAPTATIONRATIO * 50.0f

@interface GKWYArtistViewController ()<GKPageScrollViewDelegate>

@property (nonatomic, strong) GKPageScrollView          *pageScrollView;

@property (nonatomic, strong) GKWYArtistHeaderView      *headerView;

@property (nonatomic, strong) JXCategoryTitleView       *categoryView;

@property (nonatomic, strong) UIImageView               *headerBgImgView;
@property (nonatomic, strong) UIVisualEffectView        *headerBgEffectView;

@property (nonatomic, strong) GKWYArtistModel           *artistModel;

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
    self.gk_navLineHidden = YES;
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    self.gk_navTitleColor = [UIColor whiteColor];
    
    [self.view addSubview:self.headerBgImgView];
    [self.view addSubview:self.headerBgEffectView];
    [self.view addSubview:self.pageScrollView];
    
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(NAVBAR_HEIGHT, 0, 0, 0));
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(@0);
        make.width.mas_equalTo(KScreenW);
        make.height.mas_equalTo(kArtistHeaderHeight);
    }];
    
    [self.headerBgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kCriticalPoint);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.headerView.mas_top).offset(kArtistHeaderHeight - kCriticalPoint);
        make.height.mas_greaterThanOrEqualTo(NAVBAR_HEIGHT);
    }];
    
    [self.headerBgEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kCriticalPoint);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.headerView.mas_top).offset(kArtistHeaderHeight - kCriticalPoint);
        make.height.mas_greaterThanOrEqualTo(NAVBAR_HEIGHT);
    }];
    
    [self getArtistInfo];
}

- (void)getArtistInfo {
    NSString *api = [NSString stringWithFormat:@"baidu.ting.artist.getinfo&tinguid=%@&artistid=%@", self.tinguid, self.artistid];
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        self.isRequest = YES;
        
        self.artistModel = [GKWYArtistModel yy_modelWithDictionary:responseObject];
        
        self.headerView.model = self.artistModel;
        
        [self.headerBgImgView sd_setImageWithURL:[NSURL URLWithString:self.artistModel.avatar_s500]
                           placeholderImage:[UIImage imageNamed:@"cm2_default_artist_banner"]];
        
        // 刷新pageScrollView
        [self.pageScrollView reloadData];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - GKPageScrollViewDelegate
- (BOOL)shouldLazyLoadListInPageScrollView:(GKPageScrollView *)pageScrollView {
    return YES;
}

- (UIView *)headerViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.headerView;
}

- (UIView *)segmentedViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.categoryView;
}

- (id<GKPageListViewDelegate>)pageScrollView:(GKPageScrollView *)pageScrollView initListAtIndex:(NSInteger)index {
    GKWYBaseSubViewController *vc = nil;
    if (index == 0) {
        vc = [GKWYArtistSongListViewController new];
    }else if (index == 1) {
        vc = [GKWYArtistAlbumListViewController new];
    }else if (index == 2) {
        vc = [GKWYArtistVideoListViewController new];
    }else if (index == 3) {
        vc = [GKWYArtistIntroViewController new];
    }
    if (self.artistModel) {
        vc.model = self.artistModel;
    }
    [vc loadData];
    return vc;
}

- (void)mainTableViewDidScroll:(UIScrollView *)scrollView isMainCanScroll:(BOOL)isMainCanScroll {
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY >= kArtistHeaderHeight) {
        [self.headerBgImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(NAVBAR_HEIGHT);
        }];
        
        [self.headerBgEffectView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(NAVBAR_HEIGHT);
        }];
        self.headerBgEffectView.alpha = 1.0f;
    }else {
        // 0到临界点 高度不变
        if (offsetY <= 0 && offsetY >= kCriticalPoint) {
            CGFloat criticalOffsetY = offsetY - kCriticalPoint;
            
            [self.headerBgImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).offset(-criticalOffsetY);
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(self.headerView.mas_top).offset(kArtistHeaderHeight + criticalOffsetY);
            }];
            
            [self.headerBgEffectView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view).offset(-criticalOffsetY);
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(self.headerView.mas_top).offset(kArtistHeaderHeight + criticalOffsetY);
            }];
        }else { // 小于-20 下拉放大
            [self.headerBgImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view);
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(self.headerView.mas_top).offset(kArtistHeaderHeight);
            }];
            
            [self.headerBgEffectView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view);
                make.left.right.equalTo(self.view);
                make.bottom.equalTo(self.headerView.mas_top).offset(kArtistHeaderHeight);
            }];
        }
        
        // 虚化渐变
        // 0 - kWYHeaderHeight 透明度0-1
        CGFloat alpha = 0.0f;
        if (offsetY <= 0) {
            alpha = 0.0f;
        }else if (offsetY < kArtistHeaderHeight) {
            alpha = offsetY / kArtistHeaderHeight;
        }else {
            alpha = 1.0f;
        }
        self.headerBgEffectView.alpha = alpha;
    }
    
    // 标题显隐
    BOOL show = [self isAlbumNameLabelShowingOn];
    
    if (show) {
        self.gk_navTitle = @"";
    }else {
        self.gk_navTitle = self.headerView.nameLabel.text;
    }
}

- (BOOL)isAlbumNameLabelShowingOn {
    UIView *view = self.headerView.nameLabel;
    
    // 获取titlelabel在视图上的位置
    CGRect showFrame = [self.view convertRect:view.frame fromView:view.superview];
    
    showFrame.origin.y -= NAVBAR_HEIGHT;
    
    // 判断是否有重叠部分
    BOOL intersects = CGRectIntersectsRect(self.view.bounds, showFrame);
    
    return !view.isHidden && view.alpha > 0.01 && intersects;
}

#pragma mark - GKPageControllerDelegate
- (void)pageScrollViewWillBeginScroll {
    [self.pageScrollView horizonScrollViewWillBeginScroll];
}

- (void)pageScrollViewDidEndedScroll {
    [self.pageScrollView horizonScrollViewDidEndedScroll];
}

#pragma mark - 懒加载
- (GKPageScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[GKPageScrollView alloc] initWithDelegate:self];
        _pageScrollView.mainTableView.backgroundColor = [UIColor clearColor];
        _pageScrollView.ceilPointHeight = 0;
    }
    return _pageScrollView;
}

- (GKWYArtistHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [GKWYArtistHeaderView new];
    }
    return _headerView;
}

- (UIImageView *)headerBgImgView {
    if (!_headerBgImgView) {
        _headerBgImgView = [UIImageView new];
        _headerBgImgView.contentMode = UIViewContentModeScaleAspectFill;
        _headerBgImgView.clipsToBounds = YES;
    }
    return _headerBgImgView;
}

- (UIVisualEffectView *)headerBgEffectView {
    if (!_headerBgEffectView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        
        _headerBgEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _headerBgEffectView.alpha = 0;
    }
    return _headerBgEffectView;
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
        
        GKWYArtistAlbumListViewController *albumVC = [GKWYArtistAlbumListViewController new];
        
        GKWYArtistVideoListViewController *videoVC = [GKWYArtistVideoListViewController new];
        
        GKWYArtistIntroViewController *introVC = [GKWYArtistIntroViewController new];
        
        _childVCs = @[songVC, albumVC, videoVC, introVC];
    }
    return _childVCs;
}

- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kArtistSegmentHeight)];
        _categoryView.titleFont             = [UIFont systemFontOfSize:16];
        _categoryView.titleSelectedFont     = [UIFont systemFontOfSize:16];
        _categoryView.titleColor            = [UIColor blackColor];
        _categoryView.titleSelectedColor    = kAPPDefaultColor;
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorColor = kAPPDefaultColor;
        lineView.indicatorWidth = kAdaptive(60.0);
        lineView.indicatorHeight = 3.0;
        lineView.verticalMargin = kAdaptive(10.0);
        lineView.indicatorCornerRadius = 1.5;
        _categoryView.indicators = @[lineView];
        
        _categoryView.contentScrollView = self.pageScrollView.listContainerView.collectionView;
    }
    return _categoryView;
}

@end
