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

@interface GKWYAlbumViewController ()<UITableViewDataSource, UITableViewDelegate, GKDownloadManagerDelegate, GKWYListViewCellDelegate>

@property (nonatomic, strong) UITableView       *tableView;

@property (nonatomic, strong) UIImageView       *headerBgImgView;
@property (nonatomic, strong) UIView            *headerBgCoverView;
@property (nonatomic, strong) GKWYAlbumHeader   *headerView;

@property (nonatomic, strong) UIView            *sectionView;
@property (nonatomic, strong) UIImageView       *playImgView;
@property (nonatomic, strong) UILabel           *playAllLabel;
@property (nonatomic, strong) UILabel           *countLabel;

@property (nonatomic, assign) CGFloat           headerHeight;

@property (nonatomic, strong) GKWYAlbumModel    *albumModel;

@property (nonatomic, strong) NSArray           *songs;

// 下载使用
@property (nonatomic, strong) GKWYMusicModel    *currentModel;

@end

@implementation GKWYAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBackgroundColor = [UIColor clearColor];
    self.gk_navLineHidden = YES;
    self.gk_navigationItem.title = @"专辑";
    
    self.headerHeight = kAdaptive(520.0f);
    
    [self.view addSubview:self.headerBgImgView];
    [self.view addSubview:self.headerBgCoverView];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(NAVBAR_HEIGHT, 0, 0, 0));
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(@0);
        make.width.mas_equalTo(KScreenW);
        make.height.mas_equalTo(self.headerHeight);
    }];
    
    [self.headerBgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.headerView.mas_top).offset(self.headerHeight);
        make.height.mas_greaterThanOrEqualTo(NAVBAR_HEIGHT);
    }];
    
    [self.headerBgCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.headerView.mas_top).offset(self.headerHeight);
        make.height.mas_greaterThanOrEqualTo(NAVBAR_HEIGHT);
    }];
    
    [self loadAlbumInfo];
}

- (void)loadAlbumInfo {
    NSString *api = [NSString stringWithFormat:@"baidu.ting.album.getAlbumInfo&format=json&album_id=%@", self.album_id];
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        NSLog(@"%@", responseObject);
        self.albumModel = [GKWYAlbumModel yy_modelWithDictionary:responseObject[@"albumInfo"]];
        
        [self.headerBgImgView sd_setImageWithURL:[NSURL URLWithString:self.albumModel.pic_radio] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            self.headerBgImgView.image = [image blurredImageWithRadius:80.0f iterations:2 tintColor:GKColorHEX(0x000000, 0.2f)];
        }];
        
        self.headerView.model = self.albumModel;
        
        self.songs = [NSArray yy_modelArrayWithClass:[GKWYMusicModel class] json:responseObject[@"songlist"]];
        
        [self.tableView reloadData];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGKWYListViewCell forIndexPath:indexPath];
    cell.row        = indexPath.row;
    cell.model      = self.songs[indexPath.row];
    cell.isAlbum    = YES;
    cell.delegate   = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [kWYPlayerVC setPlayerList:self.songs];
    [kWYPlayerVC playMusicWithIndex:indexPath.row isSetList:YES];
    
    [self.navigationController pushViewController:kWYPlayerVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    self.countLabel.text = [NSString stringWithFormat:@"(共%@首)", self.albumModel.songs_total];
    return self.sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kAdaptive(100.0f);
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
    NSArray *tinguids = [model.all_artist_ting_uid componentsSeparatedByString:@","];
    NSArray *artists  = [model.all_artist_id componentsSeparatedByString:@","];
    if (tinguids.count == artists.count && tinguids.count > 1) {
        NSMutableArray *items = [NSMutableArray new];
        NSArray *titles = [model.artist_name componentsSeparatedByString:@","];
        
        __typeof(self) __weak weakSelf = self;
        [tinguids enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GKActionSheetItem *item = [GKActionSheetItem new];
            item.title = titles[idx];
            item.enabled = YES;
            item.clickBlock = ^{
                GKWYArtistViewController *artistVC = [GKWYArtistViewController new];
                artistVC.tinguid  = obj;
                artistVC.artistid = artists[idx];
                [weakSelf.navigationController pushViewController:artistVC animated:YES];
            };
            [items addObject:item];
        }];
        
        [GKActionSheet showActionSheetWithTitle:@"该歌曲有多个歌手" itemInfos:items];
    }else {
        GKWYArtistViewController *artistVC = [GKWYArtistViewController new];
        artistVC.tinguid  = tinguids.firstObject;
        artistVC.artistid = artists.firstObject;
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
    if (scrollView.contentOffset.y >= self.headerHeight) {
        [self.headerBgImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.height.mas_equalTo(NAVBAR_HEIGHT);
        }];
        
        [self.headerBgCoverView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.height.mas_equalTo(NAVBAR_HEIGHT);
        }];
    }else {
        [self.headerBgImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.headerView.mas_top).offset(self.headerHeight);
        }];
        
        [self.headerBgCoverView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.headerView.mas_top).offset(self.headerHeight);
        }];
    }
    
    BOOL isShowAlbumName = [self isAlbumNameLabelShowingOn];
    
    // 当专辑label显示时，标题显示专辑，当专辑label隐藏时，标题显示专辑名称
    self.gk_navigationItem.title = isShowAlbumName ? @"专辑" : self.albumModel.title;
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
- (UIImageView *)headerBgImgView {
    if (!_headerBgImgView) {
        _headerBgImgView = [UIImageView new];
        _headerBgImgView.contentMode = UIViewContentModeScaleAspectFill;
        _headerBgImgView.clipsToBounds = YES;
    }
    return _headerBgImgView;
}

- (UIView *)headerBgCoverView {
    if (!_headerBgCoverView) {
        _headerBgCoverView = [UIView new];
        _headerBgCoverView.backgroundColor = GKColorHEX(0x000000, 0.2f);
    }
    return _headerBgCoverView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView                      = [[UITableView alloc] init];
        _tableView.dataSource           = self;
        _tableView.delegate             = self;
        _tableView.separatorStyle       = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor      = [UIColor clearColor];
        _tableView.rowHeight            = kAdaptive(110.0f);
        _tableView.estimatedRowHeight   = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        [_tableView registerClass:[GKWYListViewCell class] forCellReuseIdentifier:kGKWYListViewCell];
        
        _tableView.tableHeaderView = self.headerView;
    }
    return _tableView;
}

- (GKWYAlbumHeader *)headerView {
    if (!_headerView) {
        _headerView = [[GKWYAlbumHeader alloc] init];
    }
    return _headerView;
}

- (UIView *)sectionView {
    if (!_sectionView) {
        UIView *sectionView = [UIView new];
        sectionView.frame = CGRectMake(0, 0, KScreenW, kAdaptive(100.0f));
        sectionView.backgroundColor = [UIColor whiteColor];
        
        [sectionView addSubview:self.playImgView];
        [sectionView addSubview:self.playAllLabel];
        [sectionView addSubview:self.countLabel];
        [self.playImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(sectionView).offset(kAdaptive(20.0f));
            make.centerY.equalTo(sectionView);
        }];
        
        [self.playAllLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playImgView.mas_right).offset(kAdaptive(20.0f));
            make.centerY.equalTo(sectionView);
        }];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playAllLabel.mas_right);
            make.centerY.equalTo(sectionView);
        }];
        
        _sectionView = sectionView;
    }
    return _sectionView;
}

- (UIImageView *)playImgView {
    if (!_playImgView) {
        _playImgView = [UIImageView new];
        _playImgView.image = [UIImage imageNamed:@"cm2_list_icn_play"];
    }
    return _playImgView;
}

- (UILabel *)playAllLabel {
    if (!_playAllLabel) {
        _playAllLabel           = [UILabel new];
        _playAllLabel.textColor = [UIColor blackColor];
        _playAllLabel.font      = [UIFont systemFontOfSize:16.0f];
        _playAllLabel.text      = @"播放全部";
    }
    return _playAllLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel             = [UILabel new];
        _countLabel.textColor   = GKColorGray(140.0f);
        _countLabel.font        = [UIFont systemFontOfSize:14.0f];
    }
    return _countLabel;
}

@end
