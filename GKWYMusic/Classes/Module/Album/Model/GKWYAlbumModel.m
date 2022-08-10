//
//  GKWYAlbumModel.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/11.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYAlbumModel.h"

@implementation GKWYAlbumModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"album_id"        : @"id",
             @"desc"            : @"description",
             @"commentCount"    : @"info.commentCount",
             @"shareCount"      : @"info.shareCount"
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"artist"  : [GKWYArtistModel class],
             @"artists" : [GKWYArtistModel class]
    };
}

- (NSString *)collectCount {
    if (!_collectCount) {
        _collectCount = @"0";
    }
    return _collectCount;
}

- (NSAttributedString *)nameAttr {
    if (!_nameAttr) {
        NSString *alia = self.alias.firstObject;
        if (alia) {
            alia = [NSString stringWithFormat:@"(%@)", alia];
        }
        NSString *name = self.name;
        if (alia) {
            name = [NSString stringWithFormat:@"%@%@", name, alia];
        }
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:name];
        [attr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0f], NSForegroundColorAttributeName: UIColor.blackColor} range:NSMakeRange(0, name.length)];
        if (alia) {
            NSRange range = [name rangeOfString:alia];
            [attr addAttributes:@{NSForegroundColorAttributeName: GKColorGray(131)} range:range];
        }
        _nameAttr = attr;
    }
    return _nameAttr;
}

- (NSString *)artistStr {
    if (!_artistStr) {
        __block NSString *str = nil;
        [self.artists enumerateObjectsUsingBlock:^(GKWYArtistModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (str == nil) {
                str = obj.name;
            }else {
                str = [NSString stringWithFormat:@"%@/%@", str, obj.name];
            }
        }];
        _artistStr = str;
    }
    return _artistStr;
}

- (NSAttributedString *)artistAttr {
    if (!_artistAttr) {
        if (self.artistStr) {
            NSString *artist = @"歌手";
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：%@ ", artist, self.artistStr]];
            [attr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: UIColor.grayColor} range:NSMakeRange(0, attr.length)];
            
            NSRange range = [attr.string rangeOfString:artist];
            [attr addAttributes:@{NSForegroundColorAttributeName: GKColorGray(160)} range:range];
            _artistAttr = attr;
        }
    }
    return _artistAttr;
}

- (NSString *)publishTimeStr {
    if (!_publishTimeStr) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.publishTime.integerValue / 1000];
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"yyyy-MM-dd";
        _publishTimeStr = [fmt stringFromDate:date];
    }
    return _publishTimeStr;
}

- (NSAttributedString *)artistsAttr {
    if (!_artistsAttr) {
        if (self.artistStr) {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.artistStr];
            [attr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: [UIColor grayColor]} range:NSMakeRange(0, attr.length)];
            
            if (self.keyword && [self.artistStr containsString:self.keyword]) {
                NSRange range = [attr.string rangeOfString:self.keyword];
                [attr addAttributes:@{NSForegroundColorAttributeName: KAPPSearchColor} range:range];
            }
            
            _artistsAttr = attr;
        }
    }
    return _artistsAttr;
}

- (CGFloat)cellHeight {
    if (!_cellHeight) {
        _cellHeight = kAdaptive(120.0f);
    }
    return _cellHeight;
}

- (NSString *)route_url {
    if (!_route_url) {
        _route_url = [NSString stringWithFormat:@"gkwymusic://album?id=%@", self.album_id];
    }
    return _route_url;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self yy_modelInitWithCoder:aDecoder];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

@end
