//
//  EVNCustomSearchBar.h
//  MMB_SaaS
//
//  Created by developer on 2017/9/27.
//  Copyright © 2017年 仁伯安. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EVNCustomSearchBarIconAlign)
{
    EVNCustomSearchBarIconAlignLeft,
    EVNCustomSearchBarIconAlignCenter
};

@class EVNCustomSearchBar;

@protocol EVNCustomSearchBarDelegate <UIBarPositioningDelegate>

@optional

- (BOOL)searchBarShouldBeginEditing:(EVNCustomSearchBar *)searchBar;

- (void)searchBarTextDidBeginEditing:(EVNCustomSearchBar *)searchBar;

- (BOOL)searchBarShouldEndEditing:(EVNCustomSearchBar *)searchBar;

- (void)searchBarTextDidEndEditing:(EVNCustomSearchBar *)searchBar;

- (void)searchBar:(EVNCustomSearchBar *)searchBar textDidChange:(NSString *)searchText;

- (BOOL)searchBar:(EVNCustomSearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (void)searchBarSearchButtonClicked:(EVNCustomSearchBar *)searchBar;

- (void)searchBarCancelButtonClicked:(EVNCustomSearchBar *)searchBar;

@end


/**
 * 自定义SearchBar
 */
@interface EVNCustomSearchBar : UIView<UITextInputTraits>

/**
 * 搜索框的代理
 */
@property (nullable, nonatomic, weak) id<EVNCustomSearchBarDelegate> delegate;

/**
 * 搜索框文本
 */
@property (nullable, nonatomic, copy) NSString *text;

/**
 * 搜索框文本颜色
 */
@property (nullable, nonatomic, strong) UIColor *textColor;

/**
 * 搜索框文本字体
 */
@property (nullable, nonatomic,strong) UIFont *textFont;

/**
 * 搜索框提示信息
 */
@property (nullable, nonatomic, copy) NSString *placeholder;

/**
 * 搜索框提示信息颜色
 */
@property (nullable, nonatomic, strong) UIColor *placeholderColor;

/**
 * 搜索框颜色
 */
@property (nullable, nonatomic, strong) UIColor *textFieldColor;

/**
 * 左边icon的图片
 */
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIImage *backgroundImage;

/**
 * 右边取消按钮
 */
@property (nullable, nonatomic, strong) UIButton *cancelButton;

@property (nonatomic) BOOL isHiddenCancelButton;

/**
 * 输入框的风格
 */
@property (nonatomic) UITextBorderStyle textBorderStyle;

/**
 * 键盘类型
 */
@property (nonatomic) UIKeyboardType keyboardType;

/**
 * 左边icon的位置
 */
@property (nonatomic) EVNCustomSearchBarIconAlign iconAlign;

@property (nonatomic, strong) UIView *inputAccessoryView;

@property (nonatomic, strong) UIView *inputView;

- (BOOL)isFirstResponder;
- (BOOL)resignFirstResponder;
- (BOOL)becomeFirstResponder;

- (void)setAutoCapitalizationMode:(UITextAutocapitalizationType)type;

@end

NS_ASSUME_NONNULL_END
