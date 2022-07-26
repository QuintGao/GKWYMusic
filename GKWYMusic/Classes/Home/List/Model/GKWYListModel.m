//
//  GKWYListModel.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/21.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYListModel.h"

@implementation GKWYListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"list_id"     : @"id",
             @"desc"        : @"description"
             };
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

@end
