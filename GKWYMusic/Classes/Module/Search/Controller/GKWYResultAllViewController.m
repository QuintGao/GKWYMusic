//
//  GKWYResultAllViewController.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/8/2.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYResultAllViewController.h"
#import "GKWYResultModel.h"
#import "GKWYResultTitleView.h"

@interface GKWYResultAllViewController ()

@property (nonatomic, strong) GKWYResultModel *model;

@end

@implementation GKWYResultAllViewController

- (instancetype)init {
    return [self initWithType:GKWYListType_ScrollView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self requestData];
}

- (void)initUI {
    self.scrollView.backgroundColor = GKColorGray(245);
    
    if (self.model) {
        __block UIView *lastView = nil;
        
        // 单曲
        if (self.model.song.songs.count > 0) {
            GKWYResultSongView *songView = [[GKWYResultSongView alloc] init];
            
            __weak __typeof(self) weakSelf = self;
            songView.showMoreBlock = ^{
                [weakSelf.pageVC.categoryView selectItemAtIndex:1];
            };
            
            CGFloat height = [songView heightWithModel:self.model.song];
            [self.scrollView addSubview:songView];
            [songView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastView ? lastView.mas_bottom : self.scrollView).offset(kAdaptive(30.0f));
                make.left.equalTo(@(kAdaptive(32.0f)));
                make.width.mas_equalTo(kScreenW - kAdaptive(64.0f));
                make.height.mas_equalTo(height);
            }];
            
            lastView = songView;
        }
        
        // 歌单
        if (self.model.playList.playLists.count > 0) {
            GKWYResultPlayListView *listView = [[GKWYResultPlayListView alloc] init];
            
            __weak __typeof(self) weakSelf = self;
            listView.showMoreBlock = ^{
                [weakSelf.pageVC.categoryView selectItemAtIndex:2];
            };
            
            CGFloat height = [listView heightWithModel:self.model.playList];
            [self.scrollView addSubview:listView];
            [listView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastView ? lastView.mas_bottom : self.scrollView).offset(kAdaptive(30.0f));
                make.left.equalTo(@(kAdaptive(32.0f)));
                make.width.mas_equalTo(kScreenW - kAdaptive(64.0f));
                make.height.mas_equalTo(height);
            }];
            
            lastView = listView;
        }
        
        // 专辑
        if (self.model.album.albums.count > 0) {
            GKWYResultAlbumView *albumView = [[GKWYResultAlbumView alloc] init];
            
            __weak __typeof(self) weakSelf = self;
            albumView.showMoreBlock = ^{
                [weakSelf.pageVC.categoryView selectItemAtIndex:4];
            };
            
            CGFloat height = [albumView heightWithModel:self.model.album];
            [self.scrollView addSubview:albumView];
            [albumView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastView ? lastView.mas_bottom : self.scrollView).offset(kAdaptive(30.0f));
                make.left.equalTo(@(kAdaptive(32.0f)));
                make.width.mas_equalTo(kScreenW - kAdaptive(64.0f));
                make.height.mas_equalTo(height);
            }];
        
            lastView = albumView;
        }
        
        [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
            make.bottom.equalTo(lastView.mas_bottom).offset(kAdaptive(40.0f));
        }];
    }
}

- (void)requestData {
    // type 搜索类型
    // 默认1 即单曲 , 取值意义 : 1: 单曲, 10: 专辑, 100: 歌手, 1000: 歌单, 1002: 用户, 1004: MV, 1006: 歌词, 1009: 电台, 1014: 视频, 1018:综合,
    
    NSString *api = [NSString stringWithFormat:@"search?keywords=%@&type=%zd", self.keyword, self.type];
    
    [self.loadingView startAnimation];
    [kHttpManager get:api params:nil successBlock:^(id responseObject) {
        [self.loadingView stopAnimation];
        if ([responseObject[@"code"] integerValue] == 200) {
            self.model = [GKWYResultModel yy_modelWithDictionary:responseObject[@"result"]];
            self.model.song.keyword = self.keyword;
            self.model.playList.keyword = self.keyword;
            self.model.album.keyword = self.keyword;
            [self initUI];
        }
    } failureBlock:^(NSError *error) {
        [self.loadingView stopAnimation];
        NSLog(@"搜索失败==%@", error);
    }];
}

@end
