//
//  GKWYArtistModel.m
//  GKWYMusic
//
//  Created by gaokun on 2018/5/15.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import "GKWYArtistModel.h"

@implementation GKWYArtistModel

- (NSAttributedString *)introAttr {
    if (!_introAttr) {
        NSString *intro = [self.intro componentsSeparatedByString:@"\n"].firstObject;
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:intro];
        // 设置行间距
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = kAdaptive(16.0f);
        
        [string addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0f],
                                NSParagraphStyleAttributeName: paragraphStyle
                                } range:NSMakeRange(0, string.length)];
        
        _introAttr = string;
    }
    return _introAttr;
}

- (CGFloat)introHeight {
    if (_introHeight == 0) {
        CGSize maxSize = CGSizeMake(KScreenW - kAdaptive(40.0f), CGFLOAT_MAX);
        
        _introHeight = [self.introAttr boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    }
    return _introHeight;
}

- (BOOL)hasMoreIntro {
    return [self.intro componentsSeparatedByString:@"\n"].count > 1;
}

@end
