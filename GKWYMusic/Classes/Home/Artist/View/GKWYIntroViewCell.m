//
//  GKWYIntroViewCell.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/18.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYIntroViewCell.h"

@interface GKWYIntroViewCell()

// 歌手简介
@property (nonatomic, strong) UILabel       *introNameLabel;
@property (nonatomic, strong) UILabel       *introContentLabel;
@property (nonatomic, strong) UIButton      *introBtn;

// 相似歌手
@property (nonatomic, strong) UILabel       *recNameLabel;
@property (nonatomic, strong) UIScrollView  *recScrollView;
@property (nonatomic, strong) UIView        *recLineView;

@end

@implementation GKWYIntroViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.introNameLabel];
        [self.contentView addSubview:self.introContentLabel];
        [self.contentView addSubview:self.introBtn];
        
        [self.contentView addSubview:self.recNameLabel];
        [self.contentView addSubview:self.recScrollView];
        [self.contentView addSubview:self.recLineView];
        
        [self.introNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kAdaptive(16.0f));
            make.top.equalTo(self.contentView).offset(kAdaptive(40.0f));
        }];
        
        [self.introContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kAdaptive(20.0f));
            make.right.equalTo(self.contentView).offset(-kAdaptive(20.0f));
            make.top.equalTo(self.introNameLabel.mas_bottom).offset(kAdaptive(20.0f));
        }];
        
        [self.introBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(self.introContentLabel.mas_bottom).offset(kAdaptive(40.0f));
        }];
        
        [self.recNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kAdaptive(16.0f));
            make.top.equalTo(self.introBtn.mas_bottom).offset(kAdaptive(80.0f));
        }];
        
        [self.recScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(self.recNameLabel.mas_bottom).offset(kAdaptive(20.0f));
            make.height.mas_equalTo(kAdaptive(180.0f));
        }];
        
        [self.recLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(self.recScrollView.mas_bottom).offset(kAdaptive(20.0f));
            make.height.mas_equalTo(0.5f);
        }];
    }
    return self;
}

- (void)setDataList:(NSArray *)dataList {
    _dataList = dataList;
    
    self.introNameLabel.text = [NSString stringWithFormat:@"%@简介", self.artistModel.name];
    self.introContentLabel.attributedText = self.artistModel.introAttr;
    
    if (self.artistModel.hasMoreIntro) {
        [self.recNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAdaptive(16.0f));
            make.top.equalTo(self.introBtn.mas_bottom).offset(kAdaptive(80.0f));
        }];
    }else {
        [self.recNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAdaptive(16.0f));
            make.top.equalTo(self.introContentLabel.mas_bottom).offset(kAdaptive(60.0f));
        }];
    }
    
    self.recNameLabel.text = @"相似歌手";
    
    CGFloat margin      = kAdaptive(40.0f);
    __block CGFloat x   = kAdaptive(10.0f);
    CGFloat y           = 0;
    CGFloat w           = kAdaptive(140.0f);
    CGFloat h           = kAdaptive(180.0f);
    
    [dataList enumerateObjectsUsingBlock:^(GKWYArtistRecModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKWYArtistRecView *itemView = [GKWYArtistRecView new];
        itemView.recModel = obj;
        itemView.tag = 1000 + idx;
        [self.recScrollView addSubview:itemView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recViewClick:)];
        [itemView addGestureRecognizer:tap];
        
        itemView.frame = CGRectMake(x, y, w, h);
        
        x += (w + margin);
    }];
    
    self.recScrollView.contentSize = CGSizeMake(2 * kAdaptive(10.0f) + dataList.count * w + (dataList.count - 1) * margin, 0);
}

- (void)introBtnClick:(id)sender {
    !self.introBtnClickBlock ? : self.introBtnClickBlock();
}

- (void)recViewClick:(UITapGestureRecognizer *)tap {
    NSInteger tag = tap.view.tag - 1000;
    
    GKWYArtistRecModel *model = self.dataList[tag];
    
    !self.recArtistClickBlock ? : self.recArtistClickBlock(model);
}

#pragma mark - 懒加载
- (UILabel *)introNameLabel {
    if (!_introNameLabel) {
        _introNameLabel = [UILabel new];
        _introNameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _introNameLabel.textColor = GKColorGray(50.0f);
    }
    return _introNameLabel;
}

- (UILabel *)introContentLabel {
    if (!_introContentLabel) {
        _introContentLabel = [UILabel new];
        _introContentLabel.font = [UIFont systemFontOfSize:15.0f];
        _introContentLabel.textColor = GKColorGray(100.0f);
        _introContentLabel.numberOfLines = 0;
    }
    return _introContentLabel;
}

- (UIButton *)introBtn {
    if (!_introBtn) {
        _introBtn = [UIButton new];
        [_introBtn setTitleColor:GKColorGray(150.0f) forState:UIControlStateNormal];
        _introBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_introBtn setTitle:@"完整歌手介绍 >" forState:UIControlStateNormal];
        [_introBtn addTarget:self action:@selector(introBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _introBtn;
}

- (UILabel *)recNameLabel {
    if (!_recNameLabel) {
        _recNameLabel = [UILabel new];
        _recNameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _recNameLabel.textColor = GKColorGray(50.0f);
    }
    return _recNameLabel;
}

- (UIScrollView *)recScrollView {
    if (!_recScrollView) {
        _recScrollView = [UIScrollView new];
        _recScrollView.pagingEnabled = NO;
        _recScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _recScrollView;
}

- (UIView *)recLineView {
    if (!_recLineView) {
        _recLineView = [UIView new];
        _recLineView.backgroundColor = kAppLineColor;
    }
    return _recLineView;
}

@end

@interface GKWYArtistRecView()

@property (nonatomic, strong) UIImageView   *imgView;
@property (nonatomic, strong) UILabel       *nameLabel;

@end

@implementation GKWYArtistRecView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imgView];
        [self addSubview:self.nameLabel];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.mas_equalTo(kAdaptive(140.0f));
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.centerX.equalTo(self);
        }];
    }
    return self;
}

- (void)setRecModel:(GKWYArtistRecModel *)recModel {
    _recModel = recModel;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:recModel.avatar_middle]];
    
    self.nameLabel.text = recModel.name;
}

#pragma mark - 懒加载
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [UIImageView new];
        _imgView.layer.cornerRadius = 4.0f;
        _imgView.layer.masksToBounds = YES;
    }
    return _imgView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont systemFontOfSize:14.0f];
        _nameLabel.textColor = [UIColor blackColor];
    }
    return _nameLabel;
}

@end
