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

#import "GKWYAlbumViewController.h"
#import "GKWYArtistViewController.h"
#import "GKWYVideoViewController.h"

@interface GKWYListViewController ()<GKDownloadManagerDelegate, GKWYListViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *listArr;

// 下载使用
@property (nonatomic, strong) GKWYMusicModel *currentModel;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger size;

@end

@implementation GKWYListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden = YES;
    
    [self.tableView registerClass:[GKWYListViewCell class] forCellReuseIdentifier:kGKWYListViewCell];
    self.tableView.rowHeight = kAdaptive(110.0f);
    
    // 初始化页码
    self.page = 0;
    // 初始化大小
    self.size = 20;
    
    self.tableView.mj_header = [GKRefreshHeader headerWithRefreshingBlock:^{
        self.page = 0;
        [self loadData];
    }];
    
    self.tableView.mj_footer = [GKRefreshFooter footerWithRefreshingBlock:^{
        self.page += self.size;
        [self loadData];
    }];
    self.tableView.mj_footer.hidden = YES;
    
    [self.tableView.mj_header beginRefreshing];
    
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

- (void)loadData {
    
    // 获取列表
    NSString *api = [NSString stringWithFormat:@"baidu.ting.billboard.billList&type=%zd&size=%zd&offset=%zd", self.type, self.size, self.page];
    
    if (self.page == 0) {
        [self.listArr removeAllObjects];
    }
    
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        NSArray *data = [NSArray yy_modelArrayWithClass:[GKWYMusicModel class] json:responseObject[@"song_list"]];
        
        [self.listArr addObjectsFromArray:data];
        
        [self.tableView reloadData];
        
        [self.tableView.mj_header endRefreshing];
        
        NSDictionary *billboard = responseObject[@"billboard"];
        
        self.tableView.mj_footer.hidden = NO;
        // 是否有更多数据
        if ([billboard[@"havemore"] boolValue]) {
            [self.tableView.mj_footer endRefreshing];
        }else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        
    } failureBlock:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
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
    
    [kWYPlayerVC setPlayerList:self.listArr];
    [kWYPlayerVC playMusicWithIndex:indexPath.row isSetList:YES];
    
    [self.navigationController pushViewController:kWYPlayerVC animated:YES];
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
            item.title      = titles[idx];
            item.enabled    = YES;
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

- (void)cellDidClickAlbumItem:(GKWYListViewCell *)cell model:(GKWYMusicModel *)model {
    GKWYAlbumViewController *albumVC = [GKWYAlbumViewController new];
    albumVC.album_id = model.album_id;
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
