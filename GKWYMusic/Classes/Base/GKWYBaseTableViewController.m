//
//  GKWYBaseTableViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/23.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYBaseTableViewController.h"

@interface GKWYBaseTableViewController ()

@end

@implementation GKWYBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.tipsLabel];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

- (void)gk_reloadData {
    [self.tableView reloadData];
    
    NSInteger count = [self tableView:self.tableView numberOfRowsInSection:0];
    
    if (count == 0) {
        self.tipsLabel.hidden = NO;
    }else {
        self.tipsLabel.hidden = YES;
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
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [UILabel new];
        _tipsLabel.textColor = [UIColor blackColor];
        _tipsLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _tipsLabel;
}

@end
