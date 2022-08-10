//
//  GKWYAlbumViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/11.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYAlbumViewController.h"
#import "GKWYAlbumHeader.h"
#import "GKWYAlbumModel.h"
#import "FXBlurView.h"
#import "GKWYListViewCell.h"
#import "GKActionSheet.h"
#import "GKWYArtistViewController.h"
#import "GKWYVideoViewController.h"

#define kAlbumHeaderHeight kAdaptive(430.0f)

@interface GKWYAlbumViewController ()<GKDownloadManagerDelegate, GKWYListViewCellDelegate>

@property (nonatomic, strong) GKWYAlbumHeader   *headerView;

@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UIView *layerView;

@property (nonatomic, strong) GKWYAlbumModel    *albumModel;

// 下载使用
@property (nonatomic, strong) GKWYMusicModel    *currentModel;

@end

@implementation GKWYAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self requestData];
}

- (void)initUI {
    self.gk_navBarAlpha = 0;
    self.gk_navTitle = @"专辑";
    
    self.tableView.backgroundColor = UIColor.clearColor;
    [self.tableView registerClass:[GKWYListViewCell class] forCellReuseIdentifier:@"GKWYListViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
        make.left.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view);
        }
    }];
    
    [self.view insertSubview:self.bgView belowSubview:self.tableView];
    
    self.tableView.tableHeaderView = self.headerView;
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(@0);
        make.width.mas_equalTo(kScreenW);
        make.height.mas_equalTo(kAlbumHeaderHeight);
    }];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.headerView.mas_top).offset(kAlbumHeaderHeight);
        make.height.mas_greaterThanOrEqualTo(GK_STATUSBAR_NAVBAR_HEIGHT);
    }];
}

- (void)requestData {
    NSString *api = [NSString stringWithFormat:@"album?id=%@", self.album_id];
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        if ([responseObject[@"code"] integerValue] == 200) {
            self.albumModel = [GKWYAlbumModel yy_modelWithDictionary:responseObject[@"album"]];
            self.headerView.model = self.albumModel;
            
            [self.bgView sd_setImageWithURL:[NSURL URLWithString:self.albumModel.picUrl]];
            
            NSArray *list = [NSArray yy_modelArrayWithClass:[GKWYMusicModel class] json:responseObject[@"songs"]];
            [self.dataSource addObjectsFromArray:list];
            [self.tableView reloadData];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"请求失败--%@", error);
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GKWYListViewCell" forIndexPath:indexPath];
    cell.row = indexPath.row;
    cell.model = self.dataSource[indexPath.row];
    cell.isAlbum = YES;
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
        
    [GKWYRoutes routeWithUrlString:@"gkwymusic://song" params:@{@"list": self.dataSource, @"index": @(indexPath.row)}];
}

#pragma mark - GKWYListViewCellDelegate
- (void)cellDidClickMVBtn:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    GKWYVideoViewController *videoVC = [GKWYVideoViewController new];
    videoVC.song_id = model.song_id;
    [self.navigationController pushViewController:videoVC animated:YES];
}

- (void)cellDidClickNextItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    [GKMessageTool showText:@"下一首播放"];
}

- (void)cellDidClickShareItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    [GKMessageTool showText:@"分享"];
}

- (void)cellDidClickDownloadItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    [self downloadMusicWithModel:model];
}

- (void)cellDidClickCommentItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    [GKMessageTool showText:@"评论"];
}

- (void)cellDidClickLoveItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    [self lovedMusicWithModel:model];
}

- (void)cellDidClickArtistItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    if (model.ar.count > 1) {
        NSMutableArray *items = [NSMutableArray new];

        __typeof(self) __weak weakSelf = self;
        [model.ar enumerateObjectsUsingBlock:^(GKWYArtistModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GKActionSheetItem *item = [GKActionSheetItem new];
            item.title = obj.name;
            item.enabled = YES;
            item.clickBlock = ^{
                GKWYArtistViewController *artistVC = [GKWYArtistViewController new];
                artistVC.artist_id = obj.artist_id;
                [weakSelf.navigationController pushViewController:artistVC animated:YES];
            };
            [items addObject:item];
        }];
        
        [GKActionSheet showActionSheetWithTitle:@"该歌曲有多个歌手" itemInfos:items];
    }else {
        GKWYArtistViewController *artistVC = [GKWYArtistViewController new];
        artistVC.artist_id = model.ar.firstObject.artist_id;
        [self.navigationController pushViewController:artistVC animated:YES];
    }
}

// 单个下载
- (void)downloadMusicWithModel:(GKWYMusicModel *)model {
    self.currentModel = model;
    
    if (model.isDownload) {
        GKDownloadModel *dModel = [GKDownloadModel new];
        dModel.fileID = model.song_id;
        
        [KDownloadManager removeDownloadArr:@[dModel]];
    }else {
        [GKWYMusicTool downloadMusicWithSongId:model.song_id];
    }
}

- (void)lovedMusicWithModel:(GKWYMusicModel *)model {
    model.isLove = !model.isLove;
    
    [GKWYMusicTool loveMusic:model];
    
    if (model.isLike) {
        [GKMessageTool showSuccess:@"已添加到我喜欢的音乐" toView:self.view imageName:@"cm2_play_icn_loved" bgColor:[UIColor blackColor]];
    }else {
        [GKMessageTool showText:@"已取消喜欢" toView:self.view bgColor:[UIColor blackColor]];
    }
}

#pragma mark - GKDownloadManagerDelegate
- (void)gkDownloadManager:(GKDownloadManager *)downloadManager downloadModel:(GKDownloadModel *)downloadModel stateChanged:(GKDownloadManagerState)state {
    if ([self.currentModel.song_id isEqualToString:downloadModel.fileID]) {
        
        GKActionSheetItem *downloadItem = [GKActionSheetItem new];
        
        if (state == GKDownloadManagerStateFinished) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 下载图片及歌词
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:downloadModel.fileCover]];
                [imgData writeToFile:downloadModel.fileImagePath atomically:YES];
                
                // 歌词
                NSData *lrcData = [NSData dataWithContentsOfURL:[NSURL URLWithString:downloadModel.fileLyric]];
                [lrcData writeToFile:downloadModel.fileLyricPath atomically:YES];
                
                downloadItem.title      = @"删除下载";
                downloadItem.imgName    = @"cm2_lay_icn_dlded_new";
                downloadItem.tagImgName = @"cm2_lay_icn_dlded_check";
            });
        }else {
            downloadItem.imgName    = @"cm2_lay_icn_dld_new";
            downloadItem.title      = @"下载";
        }
        
        if ([GKActionSheet hasShow]) {
            [GKActionSheet updateActionSheetItemWithIndex:1 item:downloadItem];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y >= (kAlbumHeaderHeight - kAdaptive(68.0))) {
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.height.mas_equalTo(GK_STATUSBAR_NAVBAR_HEIGHT);
        }];
        self.layerView.hidden = YES;
    }else {
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.headerView.mas_top).offset(kAlbumHeaderHeight);
        }];
        self.layerView.hidden = NO;
    }
    
    BOOL isShowAlbumName = [self isAlbumNameLabelShowingOn];
    
    // 当专辑label显示时，标题显示专辑，当专辑label隐藏时，标题显示专辑名称
    self.gk_navigationItem.title = isShowAlbumName ? @"歌单" : self.albumModel.name;
}

// 判断专辑名称label是否显示
- (BOOL)isAlbumNameLabelShowingOn {
    UIView *view = self.headerView.albumNameLabel;
    
    // 获取titlelabel在视图上的位置
    CGRect showFrame = [self.view convertRect:view.frame fromView:view.superview];
    
    showFrame.origin.y -= NAVBAR_HEIGHT;
    
    // 判断是否有重叠部分
    BOOL intersects = CGRectIntersectsRect(self.view.bounds, showFrame);
    
    return !view.isHidden && view.alpha > 0.01 && intersects;
}

#pragma mark - 懒加载
- (GKWYAlbumHeader *)headerView {
    if (!_headerView) {
        _headerView = [[GKWYAlbumHeader alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kAlbumHeaderHeight)];
    }
    return _headerView;
}

- (UIImageView *)bgView {
    if (!_bgView) {
        CGFloat width = kScreenW;
        CGFloat height = kAlbumHeaderHeight - kAdaptive(40);
        
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

@end
