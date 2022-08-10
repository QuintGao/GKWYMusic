//
//  GKWYArtistModel.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/15.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYArtistModel.h"

@implementation GKWYArtistDescModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"title" : @"ti",
             @"desc"  : @"txt"
    };
}

- (CGFloat)cellHeight {
    if (!_cellHeight) {
        _cellHeight += kAdaptive(32.0f);
        _cellHeight += [UIFont boldSystemFontOfSize:15].lineHeight;
        _cellHeight += kAdaptive(20.0f);
        _cellHeight += [GKWYMusicTool sizeWithText:self.desc font:[UIFont systemFontOfSize:14.0f] maxW:(kScreenW - kAdaptive(64.0f))].height;
    }
    return _cellHeight;
}

@end

@implementation GKWYArtistModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"artist_id"        : @"id"};
}

- (NSString *)identify {
    if (!_identify) {
        if (self.identifyTag.count > 0) {
            _identify = [self.identifyTag componentsJoinedByString:@","];
        }
    }
    return _identify;
}

- (NSAttributedString *)introAttr {
    if (!_introAttr) {
        if (self.briefDesc) {
            NSString *intro = [self.briefDesc componentsSeparatedByString:@"\n"].firstObject;
            
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:intro];
            // 设置行间距
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineSpacing = kAdaptive(16.0f);
            
            [string addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                                    NSParagraphStyleAttributeName: paragraphStyle
                                    } range:NSMakeRange(0, string.length)];
            
            _introAttr = string;
        }
    }
    return _introAttr;
}

- (CGFloat)introHeight {
    if (_introHeight == 0) {
        if (self.introAttr) {
            CGSize maxSize = CGSizeMake(KScreenW - kAdaptive(40.0f), CGFLOAT_MAX);
            
            _introHeight = [self.introAttr boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        }
    }
    return _introHeight;
}

- (BOOL)hasMoreIntro {
    return [self.briefDesc componentsSeparatedByString:@"\n"].count > 1;
}

- (NSString *)route_url {
    if (!_route_url) {
        _route_url = [NSString stringWithFormat:@"gkwymusic://artist?id=%@", self.artist_id];
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
