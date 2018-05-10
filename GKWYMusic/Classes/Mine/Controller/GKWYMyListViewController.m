//
//  GKWYMyListViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/4.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYMyListViewController.h"
#import "GKWYMyListViewCell.h"
#import "GKWYPlayerViewController.h"

@interface GKWYMyListViewController ()

@property (nonatomic, strong) NSArray *lists;

@end

@implementation GKWYMyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.type == 0) {
        self.gk_navigationItem.title = @"我喜欢的";
    }else {
        self.gk_navigationItem.title = @"我下载的";
    }
    
    [self.tableView registerClass:[GKWYMyListViewCell class] forCellReuseIdentifier:kMyListViewCellID];
    self.tableView.rowHeight = 60.0f;
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
    }];
    
    if (self.type == 0) {
        self.lists = [GKWYMusicTool lovedMusicList];
    }else {
        NSMutableArray *lists = [NSMutableArray new];
        
        [[KDownloadManager downloadedFileList] enumerateObjectsUsingBlock:^(GKDownloadModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GKWYMusicModel *model = [GKWYMusicModel new];
            model.song_id           = obj.fileID;
            model.song_name         = obj.fileName;
            model.artist_id         = obj.fileArtistId;
            model.artist_name       = obj.fileArtistName;
            model.album_id          = obj.fileAlbumId;
            model.album_title       = obj.fileArtistName;
            model.pic_huge          = obj.fileCover;
            model.pic_radio         = obj.fileCover;
            model.file_link         = obj.fileUrl;
            model.file_duration     = obj.fileDuration;
            model.file_size         = obj.fileSize;
            model.file_extension    = obj.fileFormat;
            model.lrclink           = obj.fileLyric;
            model.song_size         = obj.file_size;
            model.downloadState     = obj.state;
            
            [lists addObject:model];
        }];
        self.lists = [NSArray arrayWithArray:lists];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYMyListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMyListViewCellID forIndexPath:indexPath];
    cell.model = self.lists[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [kWYPlayerVC playMusicWithModel:self.lists[indexPath.row]];
    
    [self.navigationController pushViewController:kWYPlayerVC animated:YES];
}

@end
