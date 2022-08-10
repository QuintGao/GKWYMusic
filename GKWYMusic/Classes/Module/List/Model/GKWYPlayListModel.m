//
//  GKWYPlayListModel.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/21.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYPlayListModel.h"

@implementation GKWYPlayListCreator

@end

@implementation GKWYPlayListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"list_id"     : @"id",
             @"desc"        : @"description"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"creator"  : [GKWYPlayListCreator class]};
}

- (NSString *)formatPlayCount {
    if (!_formatPlayCount) {
        NSInteger count = [self.playCount integerValue];
        if (count >= 10000) {
            _formatPlayCount = [NSString stringWithFormat:@"%.f万", count / 10000.0];
        }else {
            _formatPlayCount = self.playCount;
        }
    }
    return _formatPlayCount;
}

- (NSAttributedString *)nameAttr {
    if (!_nameAttr) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.name];
        [attr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0f], NSForegroundColorAttributeName: GKColorGray(52)} range:NSMakeRange(0, attr.length)];
        
        if (self.keyword) {
            NSRange range = [self.name rangeOfString:self.keyword];
            [attr addAttributes:@{NSForegroundColorAttributeName: KAPPSearchColor} range:range];
        }
        _nameAttr = attr;
    }
    return _nameAttr;
}

- (NSString *)content {
    if (!_content) {
        _content = [NSString stringWithFormat:@"%@首音乐 by %@，播放%@次", self.trackCount, self.creator.nickname, self.formatPlayCount];
    }
    return _content;
}

- (CGFloat)cellHeight {
    if (!_cellHeight) {
        _cellHeight = kAdaptive(114.0f);
    }
    return _cellHeight;
}

- (NSString *)route_url {
    if (!_route_url) {
        _route_url = [NSString stringWithFormat:@"gkwymusic://playlist?id=%@", self.list_id];
    }
    return _route_url;
}

@end
