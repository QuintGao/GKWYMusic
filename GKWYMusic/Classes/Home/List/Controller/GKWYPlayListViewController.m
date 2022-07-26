//
//  GKWYPlayListViewController.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/21.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYPlayListViewController.h"
#import "GKWYPlayListHeaderView.h"
#import "GKLoadingView.h"
#import "GKWYListViewCell.h"

#define kHeaderHeight kAdaptive(430.0f)

@interface GKWYPlayListViewController ()

@property (nonatomic, strong) GKWYPlayListHeaderView *headerView;

@property (nonatomic, strong) GKWYListModel *model;

@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UIView *layerView;

@property (nonatomic, strong) GKLoadingView *loadingView;

@end

@implementation GKWYPlayListViewController

- (instancetype)init {
    return [self initWithType:GKWYListType_TableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBarAlpha = 0;
    self.gk_navTitle = @"歌单";
    
    self.tableView.backgroundColor = UIColor.clearColor;
    [self.tableView registerClass:[GKWYListViewCell class] forCellReuseIdentifier:@"GKWYListViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [self.view insertSubview:self.bgView belowSubview:self.tableView];
    
    self.tableView.tableHeaderView = self.headerView;
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(@0);
        make.width.mas_equalTo(kScreenW);
        make.height.mas_equalTo(kHeaderHeight);
    }];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.headerView.mas_top).offset(kHeaderHeight);
        make.height.mas_greaterThanOrEqualTo(GK_STATUSBAR_NAVBAR_HEIGHT);
    }];
    
    NSString *api = [NSString stringWithFormat:@"playlist/detail?id=%@", self.list_id];
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        if ([responseObject[@"code"] integerValue] == 200) {
            self.model = [GKWYListModel yy_modelWithDictionary:responseObject[@"playlist"]];
            
            [self.bgView sd_setImageWithURL:[NSURL URLWithString:self.model.coverImgUrl]];
            self.headerView.model = self.model;
            
            [self startRequestList];
        }
    } failureBlock:^(NSError *error) {
        [GKMessageTool showError:@"请求失败"];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y >= (kHeaderHeight - kAdaptive(68.0))) {
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.height.mas_equalTo(GK_STATUSBAR_NAVBAR_HEIGHT);
        }];
        self.layerView.hidden = YES;
    }else {
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.headerView.mas_top).offset(kHeaderHeight);
        }];
        self.layerView.hidden = NO;
    }
    
    BOOL isShowAlbumName = [self isAlbumNameLabelShowingOn];
    
    // 当专辑label显示时，标题显示专辑，当专辑label隐藏时，标题显示专辑名称
    self.gk_navigationItem.title = isShowAlbumName ? @"歌单" : self.model.name;
}

// 判断专辑名称label是否显示
- (BOOL)isAlbumNameLabelShowingOn {
    UIView *view = self.headerView.titleLabel;
    
    // 获取titlelabel在视图上的位置
    CGRect showFrame = [self.view convertRect:view.frame fromView:view.superview];
    
    showFrame.origin.y -= GK_STATUSBAR_NAVBAR_HEIGHT;
    
    // 判断是否有重叠部分
    BOOL intersects = CGRectIntersectsRect(self.view.bounds, showFrame);
    
    return !view.isHidden && view.alpha > 0.01 && intersects;
}

- (void)startRequestList {
    [self.tableView addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView).offset(kHeaderHeight);
        make.centerX.equalTo(self.tableView);
        make.width.mas_equalTo(kScreenW);
        make.height.mas_equalTo(80);
    }];
    [self.loadingView startAnimation];
    
    NSString *api = [NSString stringWithFormat:@"playlist/track/all?id=%@", self.model.list_id];
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        if ([responseObject[@"code"] integerValue] == 200) {
            NSArray *songs = [NSArray yy_modelArrayWithClass:[GKWYMusicModel class] json:responseObject[@"songs"]];
            [self.dataSource addObjectsFromArray:songs];
            
            [self.loadingView stopAnimation];
            [self.tableView reloadData];
        }else {
            [GKMessageTool showError:@"请求失败"];
        }
    } failureBlock:^(NSError *error) {
        [GKMessageTool showError:@"请求失败"];
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GKWYListViewCell" forIndexPath:indexPath];
    cell.row = indexPath.row;
    cell.model = self.dataSource[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kAdaptive(120.0f);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kAdaptive(88.0f))];
    view.backgroundColor = UIColor.whiteColor;
    
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.image = [[UIImage imageNamed:@"cm2_btn_play_full80x80"] changeImageWithColor:kAPPDefaultColor];
    [view addSubview:imgView];
    
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(kAdaptive(22.0f));
        make.centerY.equalTo(view);
        make.width.height.mas_equalTo(kAdaptive(48.0f));
    }];
    
    UILabel *playLabel = [[UILabel alloc] init];
    playLabel.textColor = UIColor.blackColor;
    playLabel.font = [UIFont systemFontOfSize:17.0f];
    playLabel.text = @"播放全部";
    [view addSubview:playLabel];
    [playLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(kAdaptive(22.0f));
        make.centerY.equalTo(imgView);
    }];
    
    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.textColor = GKColorGray(170.0f);
    countLabel.font = [UIFont systemFontOfSize:14.0f];
    countLabel.text = [NSString stringWithFormat:@"(%zd)", self.dataSource.count];
    [view addSubview:countLabel];
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(playLabel.mas_right);
        make.bottom.equalTo(playLabel.mas_bottom);
    }];
    
    return  self.dataSource.count > 0 ? view : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.dataSource.count > 0 ? kAdaptive(88.0) : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    [kWYPlayerVC setPlayerList:self.dataSource];
    [kWYPlayerVC playMusicWithIndex:indexPath.row isSetList:YES];
    
    [self.navigationController pushViewController:kWYPlayerVC animated:YES];
}

#pragma mark - 懒加载
- (GKWYPlayListHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[GKWYPlayListHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kHeaderHeight)];
    }
    return _headerView;
}

- (UIImageView *)bgView {
    if (!_bgView) {
        CGFloat width = kScreenW;
        CGFloat height = kHeaderHeight - kAdaptive(40);
        
        _bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        _bgView.backgroundColor = UIColor.darkGrayColor;
        
        [_bgView addSubview:self.effectView];
        [_bgView addSubview:self.layerView];
        
        [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self->_bgView);
        }];
        
        [self.layerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self->_bgView);
            make.height.mas_equalTo(kAdaptive(68.0f));
        }];
    }
    return _bgView;
}

- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    }
    return _effectView;
}

- (UIView *)layerView {
    if (!_layerView) {
        _layerView = [[UIView alloc] init];
        _layerView.backgroundColor = GKColorRGB(250, 250, 250);
        
        CGFloat radian = 10; // 弧度
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:CGPointMake(0, 0)];
        [bezierPath addQuadCurveToPoint:CGPointMake(kScreenW, 0) controlPoint:CGPointMake(kScreenW / 2, radian)];
        [bezierPath addLineToPoint:CGPointMake(kScreenW, kAdaptive(68.0))];
        [bezierPath addLineToPoint:CGPointMake(0, kAdaptive(68.0))];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = bezierPath.CGPath;
        
        _layerView.layer.mask = layer;
    }
    return _layerView;
}

- (GKLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[GKLoadingView alloc] init];
    }
    return _loadingView;
}

@end
