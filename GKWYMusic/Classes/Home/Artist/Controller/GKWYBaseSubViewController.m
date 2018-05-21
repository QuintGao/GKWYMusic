//
//  GKWYBaseSubViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/18.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYBaseSubViewController.h"
#import "GKRefreshFooter.h"

@interface GKWYBaseSubViewController ()

@property (nonatomic, assign) BOOL canScroll;//是否可以滚动

@property (nonatomic, strong) UIImageView   *loadingView;
@property (nonatomic, strong) UILabel       *loadLabel;

@end

@implementation GKWYBaseSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden = YES;
    
    [self.view addSubview:self.loadingView];
    [self.tableView addSubview:self.loadLabel];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView).offset(40.0f);
        make.centerX.equalTo(self.tableView);
    }];
    
    [self.loadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loadingView.mas_bottom).offset(10.0f);
        make.centerX.equalTo(self.loadingView);
    }];
    
    self.tableView.mj_footer = [GKRefreshFooter footerWithRefreshingBlock:^{
        self.page ++;
        
        [self loadMoreData];
    }];
    // 默认隐藏mj_footer
    self.tableView.mj_footer.hidden = YES;
    
    // 子视图进入临界点的通知
    [kNotificationCenter addObserver:self selector:@selector(acceptMsg:) name:@"EnterCriticalPoint" object:nil];
    
    // 子试图离开临界点的通知
    [kNotificationCenter addObserver:self selector:@selector(acceptMsg:) name:@"LeaveCriticalPoint" object:nil];
}

- (void)dealloc {
    [kNotificationCenter removeObserver:self];
}

#pragma mark - Publish Methods
- (void)loadData {}
- (void)loadMoreData {}

- (void)showLoading {
    self.loadingView.hidden = NO;
    self.loadLabel.hidden   = NO;
    [self.loadingView startAnimating];
}

- (void)hideLoading {
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
    self.loadLabel.hidden   = YES;
}

//接收信息，处理通知
- (void)acceptMsg:(NSNotification *)notify {
    if ([notify.name isEqualToString:@"EnterCriticalPoint"]) {
        BOOL canScroll = [notify.object[@"canScroll"] boolValue];
        if (canScroll) {
            _canScroll = YES;
            self.tableView.showsVerticalScrollIndicator = YES;
        }
    }else if([notify.name isEqualToString:@"LeaveCriticalPoint"]){
        _canScroll = NO;
        self.tableView.contentOffset = CGPointZero;
        self.tableView.showsVerticalScrollIndicator = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!_canScroll) {
        [scrollView setContentOffset:CGPointZero];
    }
    
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <= 0) {
        [kNotificationCenter postNotificationName:@"LeaveCriticalPoint" object:@{@"canScroll":@1}];
    }
}

#pragma mark - 懒加载
- (UIImageView *)loadingView {
    if (!_loadingView) {
        NSMutableArray *images = [NSMutableArray new];
        for (NSInteger i = 0; i < 4; i++) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_list_icn_loading%zd", i + 1];
            [images addObject:[[UIImage imageNamed:imageName] changeImageWithColor:kAPPDefaultColor]];
        }
        
        for (NSInteger i = 4; i > 0; i--) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_list_icn_loading%zd", i];
            [images addObject:[[UIImage imageNamed:imageName] changeImageWithColor:kAPPDefaultColor]];
        }
        
        UIImageView *loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
        loadingView.animationImages     = images;
        loadingView.animationDuration   = 0.75;
        loadingView.hidden              = YES;
        
        _loadingView = loadingView;
    }
    return _loadingView;
}

- (UILabel *)loadLabel {
    if (!_loadLabel) {
        _loadLabel              = [UILabel new];
        _loadLabel.font         = [UIFont systemFontOfSize:14.0f];
        _loadLabel.textColor    = [UIColor grayColor];
        _loadLabel.text         = @"正在加载...";
        _loadLabel.hidden       = YES;
    }
    return _loadLabel;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray new];
    }
    return _dataList;
}

@end
