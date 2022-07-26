//
//  GKWYMusicLyricCell.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/26.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYMusicLyricCell.h"

@implementation GKWYMusicLyricCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.lyricLabel];
        
        [self.lyricLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(kAdaptive(80.0f));
            make.right.equalTo(self).offset(-kAdaptive(80.0f));
            make.centerY.equalTo(self);
        }];
    }
    return self;
}

- (UILabel *)lyricLabel {
    if (!_lyricLabel) {
        _lyricLabel = [[UILabel alloc] init];
        _lyricLabel.font = [UIFont systemFontOfSize:15.0];
        _lyricLabel.textAlignment = NSTextAlignmentCenter;
        _lyricLabel.numberOfLines = 0;
    }
    return _lyricLabel;
}

@end
