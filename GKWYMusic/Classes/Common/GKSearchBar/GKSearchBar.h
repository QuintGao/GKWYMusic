//
//  GKSearchBar.h
//  GKWYMusic
//
//  Created by gaokun on 2018/5/4.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GKSearchBarIconAlign) {
    GKSearchBarIconAlignLeft,           // 搜索图标显示在左侧
    GKSearchBarIconAlignCenter          // 搜索图标显示在右侧
};

@class GKSearchBar;

@protocol GKSearchBarDelegate <UIBarPositioningDelegate>

@optional

- (BOOL)searchBarShouldBeginEditing:(GKSearchBar *)searchBar;
- (void)searchBarDidBeginEditing:(GKSearchBar *)searchBar;
- (BOOL)searchBarShouldEndEditing:(GKSearchBar *)searchBar;
- (void)searchBarDidEndEditing:(GKSearchBar *)searchBar;

- (void)searchBar:(GKSearchBar *)searchBar textDidChange:(NSString *)text;
- (BOOL)searchBar:(GKSearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(nonnull NSString *)text;
- (void)searchBarSearchBtnClicked:(GKSearchBar *)searchBar;
- (void)searchBarCancelBtnClicked:(GKSearchBar *)searchBar;
- (BOOL)searchBarShouldClear:(GKSearchBar *)searchBar;

@end

@interface GKSearchBar : UIView<UITextInputTraits>

@property (nullable, nonatomic, weak) id<GKSearchBarDelegate> delegate;

@property (nullable, nonatomic, copy) NSString  *text;
@property (nonatomic, copy) NSString            *placeholder;
@property (nonatomic, strong) UIColor           *placeholderColor;
@property (nonatomic, strong) UIImage           *iconImage;

@property (nonatomic, strong) UITextField       *textField;

@property (nonatomic, strong) UIButton          *cancelBtn;

@property (nonatomic, assign) GKSearchBarIconAlign iconAlign;
// 是否显示取消按钮
@property (nonatomic, assign) BOOL showCancelButton;

// 点击搜索后隐藏取消按钮？
@property (nonatomic, assign) BOOL hideCancelBtnWhenSearched;


@end
