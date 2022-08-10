//
//  GKWYListTagModel.m
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/20.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import "GKWYListTagModel.h"

@implementation GKWYListTagModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"tag_id"       : @"id"
             };
}

@end
