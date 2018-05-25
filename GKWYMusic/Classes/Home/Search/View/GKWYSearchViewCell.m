//
//  GKWYSearchViewCell.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/24.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYSearchViewCell.h"

@interface GKWYSearchViewCell()

@property (nonatomic, strong) UIImageView   *imgView;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UIButton      *deleteBtn;

@end

@implementation GKWYSearchViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.imgView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.deleteBtn];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kAdaptive(20.0f));
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imgView.mas_right).offset(kAdaptive(20.0f));
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-kAdaptive(20.0f));
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setModel:(GKWYTagModel *)model {
    _model = model;
    
    self.titleLabel.text = model.word;
}

- (void)deleteClick:(id)sender {
    !self.deleteClickBlock ? : self.deleteClickBlock();
}

#pragma mark - 懒加载
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [UIImageView new];
        _imgView.image = [UIImage imageNamed:@"cm2_list_search_time"];
    }
    return _imgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = GKColorRGB(44, 45, 47);
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    return _titleLabel;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton new];
        [_deleteBtn setImage:[UIImage imageNamed:@"cm2_search_icn_dlt"] forState:UIControlStateNormal];
        [_deleteBtn setImage:[UIImage imageNamed:@"cm2_search_icn_dlt_prs"] forState:UIControlStateHighlighted];
        [_deleteBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

@end
