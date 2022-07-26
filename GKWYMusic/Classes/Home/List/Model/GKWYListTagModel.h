//
//  GKWYListTagModel.h
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/20.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKWYListTagModel : NSObject

@property (nonatomic, copy) NSString *tag_id;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *hot;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;

@end

NS_ASSUME_NONNULL_END
