//
//  GKWYArtistTableView.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/17.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYArtistBaseTableView.h"
#import "GKRefreshHeader.h"
#import "GKRefreshFooter.h"

@interface GKWYArtistBaseTableView()

@property (nonatomic, strong) UIImageView *loadingView;

@end

@implementation GKWYArtistBaseTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.dataSource = self;
        self.delegate   = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.loadingView];
        [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(KScreenW);
            make.centerX.equalTo(self);
        }];
        
        self.mj_footer = [GKRefreshFooter footerWithRefreshingBlock:^{
            self.page ++;
            
            [self loadData];
        }];
        
        self.mj_footer.hidden = YES;
        
        [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentSize"];
}

- (void)loadData {}

// 显示loading
- (void)beginLoading {
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
}

// 结束loading
- (void)endLoading {
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self) {
        if (self.contentSize.height < KScreenH - kArtistSegmentHeight - NAVBAR_HEIGHT) {
            CGSize size = self.contentSize;
            size.height = KScreenH - kArtistSegmentHeight - NAVBAR_HEIGHT;
            self.contentSize = size;
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - 懒加载
- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray new];
    }
    return _dataList;
}

- (UIImageView *)loadingView {
    if (!_loadingView) {
        NSMutableArray *images = [NSMutableArray new];
        for (NSInteger i = 0; i < 6; i++) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_topbar_icn_playing%zd", i + 1];
            [images addObject:[[UIImage imageNamed:imageName] changeImageWithColor:kAPPDefaultColor]];
        }
        
        for (NSInteger i = 6; i > 0; i--) {
            NSString *imageName = [NSString stringWithFormat:@"cm2_topbar_icn_playing%zd", i];
            [images addObject:[[UIImage imageNamed:imageName] changeImageWithColor:kAPPDefaultColor]];
        }
        
        UIImageView *loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
        loadingView.animationImages = images;
        loadingView.animationDuration = 0.75;
        loadingView.hidden = YES;
        
        _loadingView = loadingView;
    }
    return _loadingView;
}

@end
