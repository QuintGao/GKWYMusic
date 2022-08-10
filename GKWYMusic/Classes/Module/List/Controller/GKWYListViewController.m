//
//  GKWYListViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/23.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYListViewController.h"
#import "GKWYListViewCell.h"
#import "GKRefreshHeader.h"
#import "GKRefreshFooter.h"
#import "GKActionSheet.h"
#import "GKWYPlayListCell.h"

#import "GKWYAlbumViewController.h"
#import "GKWYArtistViewController.h"
#import "GKWYVideoViewController.h"
#import "GKWYPlayListViewController.h"

@interface GKWYListViewController ()<GKDownloadManagerDelegate, GKWYListViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *listArr;

// 下载使用
@property (nonatomic, strong) GKWYMusicModel *currentModel;

@property (nonatomic, copy) NSString *lasttime;

@end

@implementation GKWYListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self requestData];
    
    [kNotificationCenter addObserver:self selector:@selector(reloadMusic) name:GKWYMUSIC_LOVEMUSICNOTIFICATION object:nil];
    [kNotificationCenter addObserver:self selector:@selector(reloadMusic) name:GKWYMUSIC_PLAYMUSICCHANGENOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadMusic];
    
    KDownloadManager.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    KDownloadManager.delegate = nil;
}

- (void)reloadMusic {
    [self.tableView reloadData];
}

- (void)initUI {
    self.gk_navigationBar.hidden = YES;
    
    self.layout.sectionInset = UIEdgeInsetsMake(10, 16, 10, 16);
    CGFloat itemWH = (kScreenW - 32 - 20) / 3;
    self.layout.itemSize = CGSizeMake(itemWH, itemWH + kAdaptive(16.0) + [UIFont systemFontOfSize:15.0].lineHeight * 2);
    self.layout.minimumLineSpacing = 10;
    self.layout.minimumInteritemSpacing = 10;
    [self.collectionView registerClass:[GKWYPlayListCell class] forCellWithReuseIdentifier:@"GKWYPlayListCell"];
    
    self.collectionView.mj_header = [GKRefreshHeader headerWithRefreshingBlock:^{
        self.lasttime = @"";
        [self loadData];
    }];
    
    self.collectionView.mj_footer = [GKRefreshFooter footerWithRefreshingBlock:^{
        [self loadData];
    }];
    
    self.collectionView.mj_footer.hidden = YES;
}

- (void)requestData {
    self.lasttime = @"";
    [self.loadingView startAnimation];
    [self loadData];
}

- (void)loadData {
    // 获取列表
    NSString *api = [NSString stringWithFormat:@"top/playlist/highquality"];
    NSDictionary *params = @{@"limit": @20, @"cat": self.tagModel.name, @"before": self.lasttime};
    
    [kHttpManager get:api params:params successBlock:^(id responseObject) {
        [self.loadingView stopAnimation];
        [self.collectionView.mj_header endRefreshing];
        self.collectionView.mj_footer.hidden = NO;
        if ([responseObject[@"code"] integerValue] == 200) {
            if ([self.lasttime isEqualToString:@""]) {
                [self.dataSource removeAllObjects];
            }
            
            BOOL more = [responseObject[@"more"] boolValue];
            if (more) {
                self.lasttime = [NSString stringWithFormat:@"%@", responseObject[@"lasttime"]];
                [self.collectionView.mj_footer endRefreshing];
            }else {
                self.lasttime = @"";
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
            
            NSArray *list = [NSArray yy_modelArrayWithClass:[GKWYPlayListModel class] json:responseObject[@"playlists"]];
            [self.dataSource addObjectsFromArray:list];
            [self.collectionView reloadData];
        }else {
            [self.tableView.mj_footer endRefreshing];
            [GKMessageTool showError:@"请求失败"];
        }
    } failureBlock:^(NSError *error) {
        [self.loadingView stopAnimation];
        self.collectionView.mj_footer.hidden = NO;
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView.mj_footer endRefreshing];
    }];
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GKWYPlayListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GKWYPlayListCell" forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    GKWYPlayListModel *model = self.dataSource[indexPath.row];
    [GKWYRoutes routeWithUrlString:model.route_url];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGKWYListViewCell forIndexPath:indexPath];
    cell.row      = indexPath.row;
    if (indexPath.row < self.listArr.count) {
        cell.model = self.listArr[indexPath.row];
    }
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [GKWYRoutes routeWithUrlString:@"gkwymusic://song" params:@{@"list": self.listArr, @"index": @(indexPath.row)}];
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
            item.title      = obj.name;
            item.enabled    = YES;
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

- (void)cellDidClickAlbumItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    GKWYAlbumViewController *albumVC = [GKWYAlbumViewController new];
    albumVC.album_id = model.al.album_id;
    [self.navigationController pushViewController:albumVC animated:YES];
}

- (void)cellDidClickMVItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    GKWYVideoViewController *videoVC = [GKWYVideoViewController new];
    videoVC.song_id = model.song_id;
    [self.navigationController pushViewController:videoVC animated:YES];
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

#pragma mark - 懒加载
- (NSMutableArray *)listArr {
    if (!_listArr) {
        _listArr = [NSMutableArray new];
    }
    return _listArr;
}

@end
