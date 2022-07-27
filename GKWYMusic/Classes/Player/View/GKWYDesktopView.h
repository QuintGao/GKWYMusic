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

- (void)startPlay;
- (void)stopPlay;

@end

NS_ASSUME_NONNULL_END
