//
//  GKWYArtistResultViewController.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/3.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYArtistResultViewController.h"
#import "GKWYArtistViewCell.h"

@interface GKWYArtistResultViewController ()

@end

@implementation GKWYArtistResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden = YES;
    
    [self.tableView registerClass:[GKWYArtistViewCell class] forCellReuseIdentifier:kArtistViewCellID];
    self.tableView.rowHeight = 60.0f;
    
    self.tipsLabel.text = @"无结果";
}

- (void)setArtists:(NSArray *)artists {
    _artists = artists;
    
    [self gk_reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.artists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYArtistViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kArtistViewCellID forIndexPath:indexPath];
    cell.model = self.artists[indexPath.row];
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
