//
//  GKWYArtistHeaderView.m
//  GKWYMusic
//
//  Created by gaokun on 2018/10/11.
//  Copyright © 2018 gaokun. All rights reserved.
//

#import "GKWYArtistHeaderView.h"
#import "GKWYArrowView.h"

@interface GKWYArtistHeaderView()

@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) GKWYArrowView *briefView;

@end

@implementation GKWYArtistHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.nameLabel];
        [self addSubview:self.tagLabel];
        [self addSubview:self.briefView];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.tagLabel);
            make.bottom.equalTo(self.tagLabel.mas_top).offset(-kAdaptive(40.0f));
        }];
        
        [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.briefView.mas_top).offset(-kAdaptive(20.0f));
            make.left.equalTo(self.briefView);
        }];
        
        [self.briefView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAdaptive(30.0f));
            make.right.equalTo(self).offset(-kAdaptive(30.0f));
            make.bottom.equalTo(self).offset(-kAdaptive(26.0f));
        }];
    }
    return self;
}

- (void)setModel:(GKWYArtistModel *)model {
    _model = model;
    
    self.nameLabel.text = model.name;
    
    self.tagLabel.text = model.identify;
    
    self.briefView.contentLabel.text = model.briefDesc;
}

#pragma mark - 懒加载
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _nameLabel.textColor = [UIColor whiteColor];
    }
    return _nameLabel;
}

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [UILabel new];
        _tagLabel.font = [UIFont systemFontOfSize:13.0f];
        _tagLabel.textColor = [UIColor whiteColor];
    }
    return _tagLabel;
}

- (GKWYArrowView *)briefView {
    if (!_briefView) {
        _briefView = [[GKWYArrowView alloc] init];
    }
    return _briefView;
}

@end
