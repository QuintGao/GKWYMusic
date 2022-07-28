//
//  GKWYDesktopView.h
//  GKWYMusic
//
//  Created by QuintGao on 2022/7/27.
//  Copyright © 2022 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKWYDesktopView : UIView

@property (nonatomic, copy) NSString *diskImageUrl;

@property (nonatomic, copy) NSString *lyric;

@property (nonatomic, copy) void(^playBtnClickBlock)(void);
@property (nonatomic, copy) void(^prevBtnClickBlock)(void);
@property (nonatomic, copy) void(^nextBtnClickBlock)(void);

- (void)startPlay;
- (void)stopPlay;
- (void)updateProgress:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
