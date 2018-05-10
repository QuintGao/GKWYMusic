## EVNCustomSearchBar
🔍Born for iOS 11 and iPhone X SearchBar

[![Build Status](https://travis-ci.org/zonghongyan/EVNCustomSearchBar.svg?branch=master)](https://travis-ci.org/zonghongyan/EVNTouchIDDemo)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/EVNCustomSearchBar.svg)](https://img.shields.io/cocoapods/v/EVNCustomSearchBar.svg)
[![License](https://img.shields.io/github/license/zonghongyan/EVNCustomSearchBar.svg?style=flat)](https://github.com/zonghongyan/EVNCustomSearchBar/blob/master/LICENSE)

### 预览图

<img src="https://github.com/zonghongyan/EVNCustomSearchBar/blob/master/EVNCustomSearchBarDemo/EVNCustomSearchBar.gif" width="20%" height="20%" alt="other iPhone" >

<img src="https://github.com/zonghongyan/EVNCustomSearchBar/blob/master/EVNCustomSearchBarDemo/EVNCustomSearchBar2.gif" width="20%" height="20%" alt="iPhone " >


## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build EVNCustomSearchBar.

To integrate EVNCustomSearchBar into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
#use_frameworks!

target '<Your Target Name>' do

pod 'EVNCustomSearchBar', '~> 0.1.1'

end
```

Then, run the following command:

```bash
$ pod install
```

### Use
```
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self initSearchBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark: 设置顶部导航搜索部分
- (void)initSearchBar
{
    self.navigationItem.titleView = self.searchBar;
    if (@available(iOS 11.0, *))
    {
        [self.searchBar.heightAnchor constraintLessThanOrEqualToConstant:kEVNScreenNavigationBarHeight].active = YES;
    }
    else
    {

    }


}

#pragma mark: getter method EVNCustomSearchBar
- (EVNCustomSearchBar *)searchBar
{
    if (!_searchBar)
    {
        _searchBar = [[EVNCustomSearchBar alloc] initWithFrame:CGRectMake(0, kEVNScreenStatusBarHeight, kEVNScreenWidth, kEVNScreenNavigationBarHeight)];

        _searchBar.backgroundColor = [UIColor clearColor]; // 清空searchBar的背景色
        _searchBar.iconImage = [UIImage imageNamed:@"EVNCustomSearchBar.bundle/searchImageBlack.png"];
//        _searchBar.iconImage = [UIImage imageNamed:@"EVNCustomSearchBar.bundle/searchImageTextColor.png"];
        _searchBar.iconAlign = EVNCustomSearchBarIconAlignCenter;
        [_searchBar setPlaceholder:@"请输入关键字"];  // 搜索框的占位符
        _searchBar.placeholderColor = TextGrayColor;
        _searchBar.delegate = self; // 设置代理
        [_searchBar sizeToFit];
    }
    return _searchBar;
}

#pragma mark: EVNCustomSearchBar delegate method
- (BOOL)searchBarShouldBeginEditing:(EVNCustomSearchBar *)searchBar
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
    return YES;
}

- (void)searchBarTextDidBeginEditing:(EVNCustomSearchBar *)searchBar
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (BOOL)searchBarShouldEndEditing:(EVNCustomSearchBar *)searchBar
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
    return YES;
}

- (void)searchBarTextDidEndEditing:(EVNCustomSearchBar *)searchBar
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (void)searchBar:(EVNCustomSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (BOOL)searchBar:(EVNCustomSearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
    return YES;
}

- (void)searchBarSearchButtonClicked:(EVNCustomSearchBar *)searchBar
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (void)searchBarCancelButtonClicked:(EVNCustomSearchBar *)searchBar
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.searchBar resignFirstResponder];
}
```
