//
//  GKWYMusicListView.m
//  GKWYMusic
//
//  Created by gaokun on 2018/4/23.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYMusicListView.h"

@interface GKWYMusicListView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView    *topView;
@property (nonatomic, strong) UIView    *topLine;
@property (nonatomic, strong) UIButton  *topBtn;
@property (nonatomic, strong) UILabel   *countLabel;
@property (nonatomic, strong) UIButton  *closeBtn;
@property (nonatomic, strong) UIView    *closeLine;

@property (nonatomic, strong) UITableView *listTable;

@end

@implementation GKWYMusicListView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.topView];
        [self addSubview:self.listTable];
        [self addSubview:self.closeBtn];
        
        [self.topView addSubview:self.topLine];
        [self.topView addSubview:self.topBtn];
        [self.topView addSubview:self.countLabel];
        
        [self.closeBtn addSubview:self.closeLine];
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.mas_equalTo(50.0f);
        }];
        
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(50.0f);
        }];
        
        [self.listTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self.topView.mas_bottom);
            make.bottom.equalTo(self.closeBtn.mas_top);
        }];
        
        [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.topView);
            make.height.mas_equalTo(0.5f);
        }];
        
        [self.topBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topView).offset(10.0f);
            make.centerY.equalTo(self.topView);
        }];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topBtn.mas_right).offset(5.0f);
            make.centerY.equalTo(self.topView);
        }];
        
        [self.closeLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.closeBtn);
            make.height.mas_equalTo(0.5);
        }];
        
        [kNotificationCenter addObserver:self selector:@selector(statusChanged:) name:GKWYMUSIC_PLAYSTATECHANGENOTIFICATION object:nil];
        [kNotificationCenter addObserver:self selector:@selector(playerChanged:) name:GKWYMUSIC_PLAYMUSICCHANGENOTIFICATION object:nil];
    }
    return self;
}

- (void)dealloc {
    [kNotificationCenter removeObserver:self];
}

- (void)statusChanged:(NSNotification *)notify {
    [self.listTable reloadData];
}

- (void)playerChanged:(NSNotification *)notify {
    [self.listTable reloadData];
}

- (void)closeBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(listViewDidClose:)]) {
        [self.delegate listViewDidClose:self];
    }
}

- (void)setListArr:(NSArray *)listArr {
    _listArr = listArr;
    
//    self.countLabel.text = [NSString stringWithFormat:@"%zd首", listArr.count];
    
    switch (kWYPlayerVC.playStyle) {
        case GKWYPlayerPlayStyleLoop:{      // 列表循环
            [self.topBtn setImage:[[UIImage imageNamed:@"cm2_icn_loop"] changeImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
            [self.topBtn setTitle:[NSString stringWithFormat:@"列表循环(%zd)", listArr.count] forState:UIControlStateNormal];
        }
            break;
        case GKWYPlayerPlayStyleOne:{       // 单曲循环
            [self.topBtn setImage:[[UIImage imageNamed:@"cm2_icn_one"] changeImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
            [self.topBtn setTitle:@"单曲循环" forState:UIControlStateNormal];
        }
            break;
        case GKWYPlayerPlayStyleRandom:{    // 随机播放
            [self.topBtn setImage:[[UIImage imageNamed:@"cm2_icn_shuffle"] changeImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
            [self.topBtn setTitle:[NSString stringWithFormat:@"随机播放(%zd)", listArr.count] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    
    __block NSInteger playIndex = 0;
    [listArr enumerateObjectsUsingBlock:^(GKWYMusicModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isPlaying) {
            playIndex = idx;
            *stop = YES;
        }
    }];
    
    [self.listTable reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:playIndex inSection:0];
        
        [self.listTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    });
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKWYMusicListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kWYMusicListViewCellID forIndexPath:indexPath];
    
    cell.model = self.listArr[indexPath.row];
    
//    cell.likeClicked = ^(GKWYMusicModel *model) {
//        if ([self.delegate respondsToSelector:@selector(listView:didLovedWithRow:)]) {
//            [self.delegate listView:self didLovedWithRow:indexPath.row];
//        }
//    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(listView:didSelectRow:)]) {
        [self.delegate listView:self didSelectRow:indexPath.row];
    }
}

#pragma mark - 懒加载
- (UIView *)topView {
    if (!_topView) {
        _topView = [UIView new];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [UIView new];
        _topLine.backgroundColor = GKColorGray(222);
    }
    return _topLine;
}

- (UIButton *)topBtn {
    if (!_topBtn) {
        _topBtn = [UIButton new];
        [_topBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _topBtn;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel             = [UILabel new];
        _countLabel.font        = [UIFont systemFontOfSize:13.0f];
        _countLabel.textColor   = [UIColor lightGrayColor];
    }
    return _countLabel;
}

- (UITableView *)listTable {
    if (!_listTable) {
        _listTable = [UITableView new];
        _listTable.dataSource = self;
        _listTable.delegate   = self;
        _listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_listTable registerClass:[GKWYMusicListViewCell class] forCellReuseIdentifier:kWYMusicListViewCellID];
        _listTable.rowHeight = 44;
        if (@available(iOS 11.0, *)) {
            _listTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    return _listTable;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton new];
        _closeBtn.backgroundColor = [UIColor whiteColor];
        [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIView *)closeLine {
    if (!_closeLine) {
        _closeLine = [UIView new];
        _closeLine.backgroundColor = GKColorGray(222);
    }
    return _closeLine;
}

@end

@interface GKWYMusicListViewCell()

@property (nonatomic, strong) UIImageView   *playImgView;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel       *artistLabel;
@property (nonatomic, strong) UIView        *lineView;

@end

@implementation GKWYMusicListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.playImgView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.artistLabel];
        [self.contentView addSubview:self.lineView];
        
        [self.playImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10.0f);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10.0f);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel.mas_right).offset(5.0f);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(10.0f);
            make.height.mas_equalTo(0.5f);
        }];
    }
    return self;
}

- (void)setModel:(GKWYMusicModel *)model {
    _model = model;
    
    self.nameLabel.text     = model.song_name;
    self.artistLabel.text   = [NSString stringWithFormat:@"- %@", model.artist_name];
    
    if (model.isPlaying) {
        self.playImgView.hidden     = NO;
        self.nameLabel.textColor    = kAPPDefaultColor;
        self.artistLabel.textColor  = kAPPDefaultColor;
        
        self.playImgView.image = [UIImage imageNamed:@"cm2_icn_volume"];
        
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.playImgView.mas_right).offset(5.0f);
            make.centerY.equalTo(self.contentView);
        }];
    }else {
        self.playImgView.hidden = YES;
        [self.playImgView stopAnimating];
        
        self.nameLabel.textColor    = [UIColor blackColor];
        self.artistLabel.textColor  = [UIColor lightGrayColor];
        
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10.0f);
            make.centerY.equalTo(self.contentView);
        }];
    }
}

#pragma mark - 懒加载
- (UIImageView *)playImgView {
    if (!_playImgView) {
        _playImgView = [UIImageView new];
    }
    return _playImgView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font      = [UIFont systemFontOfSize:16.0f];
    }
    return _nameLabel;
}

- (UILabel *)artistLabel {
    if (!_artistLabel) {
        _artistLabel = [UILabel new];
        _artistLabel.textColor = [UIColor lightGrayColor];
        _artistLabel.font      = [UIFont systemFontOfSize:14.0f];
    }
    return _artistLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = GKColorGray(222);
    }
    return _lineView;
}

@end
