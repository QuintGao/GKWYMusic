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

@interface GKWYAlbumViewController ()<UITableViewDataSource, UITableViewDelegate>

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

@property (nonatomic, strong) GKWYMusicModel    *currentModel;

@end

@implementation GKWYAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBackgroundColor = [UIColor clearColor];
    
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
    cell.row   = indexPath.row;
    cell.model = self.songs[indexPath.row];
//    cell.moreClicked = ^(GKWYMusicModel *model) {
//        self.currentModel = model;
//        
//        [self showActionSheetWithModel:model];
//    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYMusicModel *model = self.songs[indexPath.row];
    
    [kWYPlayerVC playMusicWithModel:model];
    
    [self.navigationController pushViewController:kWYPlayerVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    self.countLabel.text = [NSString stringWithFormat:@"(共%@首)", self.albumModel.songs_total];
    return self.sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kAdaptive(100.0f);
}

#pragma mark - Private Methods
- (void)showActionSheetWithModel:(GKWYMusicModel *)model {
    GKActionSheetItem *shareItem = [GKActionSheetItem new];
    shareItem.imgName = @"cm2_lay_icn_share_new";
    shareItem.title   = @"分享";
    
    GKActionSheetItem *downloadItem = [GKActionSheetItem new];
    if (model.isDownload) {
        downloadItem.title      = @"删除下载";
        downloadItem.imgName    = @"cm2_lay_icn_dlded_new";
        downloadItem.tagImgName = @"cm2_lay_icn_dlded_check";
    }else {
        downloadItem.imgName    = @"cm2_lay_icn_dld_new";
        downloadItem.title      = @"下载";
    }
    
    GKActionSheetItem *commentItem = [GKActionSheetItem new];
    commentItem.imgName = @"cm2_lay_icn_cmt_new";
    commentItem.title   = @"评论";
    
    GKActionSheetItem *loveItem = [GKActionSheetItem new];
    if (model.isLike) {
        loveItem.title = @"取消喜欢";
        loveItem.imgName = @"cm2_lay_icn_loved";
    }else {
        loveItem.title = @"喜欢";
        loveItem.image = [[UIImage imageNamed:@"cm2_lay_icn_love"] changeImageWithColor:kAPPDefaultColor];
    }
    
    GKActionSheetItem *artistItem = [GKActionSheetItem new];
    artistItem.title = [NSString stringWithFormat:@"歌手：%@", model.artist_name];
    artistItem.imgName = @"cm2_lay_icn_artist_new";
    
    [GKActionSheet showActionSheetWithTitle:[NSString stringWithFormat:@"歌曲:%@", model.song_name] itemInfos:@[shareItem, downloadItem, commentItem, loveItem, artistItem] selectedBlock:^(NSInteger idx) {
        switch (idx) {
            case 0: {   // 分享
                
            }
                break;
            case 1: {   // 下载
                [self downloadMusicWithModel:model];
            }
                break;
            case 2: {   // 评论
                
            }
                break;
            case 3: {   // 喜欢
                [self lovedMusicWithModel:model];
            }
                break;
            case 4: {   // 歌手
            }
                break;
                
            default:
                break;
        }
    }];
}

// 单个下载
- (void)downloadMusicWithModel:(GKWYMusicModel *)model {
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
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource   = self;
        _tableView.delegate     = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.rowHeight = 54.0f;
        _tableView.estimatedRowHeight = 0;
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
