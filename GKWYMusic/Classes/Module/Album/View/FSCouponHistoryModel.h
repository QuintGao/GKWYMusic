//
//  FSCouponHistoryModel.h
//  FilmSiteClient
//
//  Created by QuintGao on 2022/8/4.
//  Copyright © 2022 M1905. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSCouponHistoryTab : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger is_selected;
@property (nonatomic, copy) NSString *pagetype;

@end

@interface FSCouponHistoryModel : NSObject

@end

@interface FSVIPConversionHistoryModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *mode;
@property (nonatomic, copy) NSString *card_number;
@property (nonatomic, copy) NSString *duration;

@end

NS_ASSUME_NONNULL_END
