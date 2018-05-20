//
//  GKWYAlbumResultViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/3.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYAlbumResultViewController.h"
#import "GKWYAlbumViewCell.h"

@interface GKWYAlbumResultViewController ()

@end

@implementation GKWYAlbumResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden = YES;
    
    [self.tableView registerClass:[GKWYAlbumViewCell class] forCellReuseIdentifier:kAlbumViewCellID];
    self.tableView.rowHeight = 60.0f;
    
    self.tipsLabel.text = @"无结果";
}

- (void)setAlbums:(NSArray *)albums {
    _albums = albums;
    
    [self gk_reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYAlbumViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumViewCellID forIndexPath:indexPath];
    cell.model = self.albums[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    GKWYSongModel *songModel = self.artists[indexPath.row];
    //
    //    GKWYMusicModel *model = [GKWYMusicModel new];
    //    model.song_id       = songModel.songid;
    //    model.song_name     = songModel.songname;
    //    model.artist_name   = songModel.artistname;
    //
    //    [kWYPlayerVC playMusicWithModel:model];
}

@end
