## GKNavigationBarViewController

[![Build Status](http://img.shields.io/travis/QuintGao/GKNavigationBarViewController/master.svg?style=flat)](https://travis-ci.org/QuintGao/GKNavigationBarViewController)
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/QuintGao/GKNavigationBarViewController/master/LICENSE)
[![platform](http://img.shields.io/cocoapods/p/GKNavigationBarViewController.svg?style=flat)](http://cocoadocs.org/docsets/GKNavigationBarViewController)
[![languages](https://img.shields.io/badge/language-objective--c-blue.svg)](#)
[![cocoapods](http://img.shields.io/cocoapods/v/GKNavigationBarViewController.svg?style=flat)](https://cocoapods.org/pods/GKNavigationBarViewController)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/QuintGao/GKNavigationBarViewController)
[![support](https://img.shields.io/badge/support-ios%208%2B-orange.svg)](#) 


iOS自定义导航栏 - 导航栏联动效果

## 导航栏联动的实现方法
  [iOS自定义导航栏-导航栏联动（一）](http://www.jianshu.com/p/5662cdf4393e),[GKNavigationController](https://github.com/QuintGao/GKNavigationController)

  [iOS自定义导航栏-导航栏联动（二）](http://www.jianshu.com/p/5ba9b12ec933),[GKNavigationBarViewController](https://github.com/QuintGao/GKNavigationBarViewController)
  
## 重要
1、有时修改状态栏会闪动（从黑色变成白色等）或状态栏颜色显示异常（左边黑色右边白色登）

    在UIViewController的init方法中修改gk_statusBarStyle即可
  
## GKNavigationBar

该库的另一种实现方式[GKNavigationBar](https://github.com/QuintGao/GKNavigationBar)，无侵入性，耦合度低，推荐使用

## 说明：

现在大多数的APP都有导航栏联动效果，即滑动返回的时候导航栏也跟着一起返回，比如：网易新闻，网易云音乐，腾讯视频等等，于是通过查找一些资料及其他库的做法，自己也写了一个框架，可以让每一个控制器都拥有自己的导航栏，可以很方便的改变导航栏的样式等

## 介绍：(本框架的特性)

    * 支持自定义导航栏样式（隐藏、透明等）
    * 支持控制器开关返回手势
    * 支持控制器开关全屏返回手势
    * 支持控制器设置导航栏透明度，可实现渐变效果
    * 完美解决UITableView，UIScrollView滑动手势冲突
    * 可实现push，pop时控制器缩放效果（如：今日头条）
    * 可实现左滑push一个控制器的效果（如：网易新闻）

## Demo中部分截图如下

![今日头条](https://github.com/QuintGao/GKNavigationBarViewController/blob/master/imgs/%E4%BB%8A%E6%97%A5%E5%A4%B4%E6%9D%A1.gif)
 
![网易云音乐](https://github.com/QuintGao/GKNavigationBarViewController/blob/master/imgs/%E7%BD%91%E6%98%93%E4%BA%91%E9%9F%B3%E4%B9%90.gif)

![网易新闻](https://github.com/QuintGao/GKNavigationBarViewController/blob/master/imgs/%E7%BD%91%E6%98%93%E6%96%B0%E9%97%BB.gif)

![抖音](https://github.com/QuintGao/GKNavigationBarViewController/blob/master/imgs/douyin.gif)


## 使用说明

1. 今日头条的实现

UINavigationController作为根控制器，包含一个UITabBarController，UITabBarController中包含以GKNavigationBarViewController为父类的子类

导航栏创建方式
```
GKToutiaoViewController *toutiaoVC = [GKToutiaoViewController new];

// 根控制器是导航控制器，需要缩放
UINavigationController *nav = [UINavigationController rootVC:toutiaoVC translationScale:YES];

```

2. 网易云音乐的实现

UITabBarController作为根控制器，包含带导航栏的以GKNavigationBarViewController为父类的子类

3. 网易新闻的实现

UITabBarController作为根控制器，包含带导航栏的以GKNavigationBarViewController为父类的子类
其中导航栏开启左滑push手势，主要代码如下：
```
// 导航栏开启左滑push
UINavigationController *nav = [UINavigationController rootVC:vc translationScale:NO];
nav.gk_openScrollLeftPush = YES;

// 单个控制器中设置左滑push代理，并实现方法
1. // 设置push的代理
self.gk_pushDelegate = self;

2. 实现代理方法
- (void)pushToNextViewController {
    GKWYNewsCommentViewController *detailVC = [GKWYNewsCommentViewController new];
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

```

4. 部分属性介绍

UINavigationController
```
/** 导航栏转场时是否缩放,此属性只能在初始化导航栏的时候有效，在其他地方设置会导致错乱 */
@property (nonatomic, assign, readonly) BOOL gk_translationScale;

/** 是否开启左滑push操作，默认是NO */
@property (nonatomic, assign) BOOL gk_openScrollLeftPush;

```

UIViewController
```
/** 是否禁止当前控制器的滑动返回(包括全屏返回和边缘返回) */
@property (nonatomic, assign) BOOL gk_interactivePopDisabled;

/** 是否禁止当前控制器的全屏滑动返回 */
@property (nonatomic, assign) BOOL gk_fullScreenPopDisabled;

/** 全屏滑动时，滑动区域距离屏幕左边的最大位置，默认是0：表示全屏都可滑动 */
@property (nonatomic, assign) CGFloat gk_popMaxAllowedDistanceToLeftEdge;

/** 设置导航栏的透明度 */
@property (nonatomic, assign) CGFloat gk_navBarAlpha;

/** push代理 */
@property (nonatomic, assign) id<GKViewControllerPushDelegate> gk_pushDelegate;
```

GKNavigationBarViewController
```
/**
自定义导航条
*/
@property (nonatomic, strong, readonly) UINavigationBar *gk_navigationBar;

/**
自定义导航栏栏目
*/
@property (nonatomic, strong, readonly) UINavigationItem *gk_navigationItem;

#pragma mark - 额外的快速设置导航栏的属性
@property (nonatomic, strong) UIColor *gk_navBarTintColor;
@property (nonatomic, strong) UIColor *gk_navBackgroundColor;
@property (nonatomic, strong) UIImage *gk_navBackgroundImage;
@property (nonatomic, strong) UIColor *gk_navTintColor;
@property (nonatomic, strong) UIView *gk_navTitleView;
@property (nonatomic, strong) UIColor *gk_navTitleColor;
@property (nonatomic, strong) UIFont *gk_navTitleFont;

@property (nonatomic, strong) UIBarButtonItem *gk_navLeftBarButtonItem;
@property (nonatomic, strong) NSArray<UIBarButtonItem *> *gk_navLeftBarButtonItems;

@property (nonatomic, strong) UIBarButtonItem *gk_navRightBarButtonItem;
@property (nonatomic, strong) NSArray<UIBarButtonItem *> *gk_navRightBarButtonItems;
```

## Cocoapods(已支持)
pod 'GKNavigationBarViewController'

## 缺陷及不足
* 不能使用系统导航栏的各种属性及方法

## 时间记录(倒序)
* 2020.04.07 -- 2.4.7 优化代码，修复已知问题
* 2020.03.34 -- 2.4.5 修改crash
* 2020.01.14 -- 2.4.4 修复设置某个导航栏间距后其他导航栏间距不准确问题
* 2019.12.24 -- 2.4.2 修复默认返回按钮不显示问题，项目结构调整
* 2019.12.22 -- 2.4.1 优化代码，解决改变状态栏颜色无效的bug
* 2019.11.04 -- 2.4.0 优化部分代码及功能
* 2019.10.17 -- 2.3.7 优化代码，删除弃用方法，增加对Carthage的支持
* 2019.10.10 -- 2.3.6 优化带tabbar的控制器的push、pop动画，已知bug修复
* 2019.8.2     -- 2.3.4 适配iOS13，优化导航栏左右item间距的处理
* 2019.7.18   -- 2.3.3 修复滑动返回手势与其他手势冲突的bug
* 2019.6.18   -- 2.3.2 优化导航栏item设置为nil时可能出现的问题
* 2019.5.28   -- 2.3.0 优化导航栏分割线的处理及创建方式
* 2019.5.24   -- 2.2.6 优化导航栏左右item间距的处理方法
* 2019.5.5     -- 2.2.5 增加自定义缩放转场动画时的偏移量
* 2019.4.21   -- 2.2.4 增加push、pop滑动过渡时的临界值
* 2019.3.15   -- 2.2.3 增加禁止手势冲突处理属性，可对某个UISCrollView单独处理
* 2019.3.5     -- 2.2.2 优化根控制器的gk_popDelegate功能失效问题
* 2019.2.24   -- 2.2.1 增加gk_popDelegate，实现该协议原来的右滑返回操作将失效
* 2019.1.17   -- 2.2.0 优化push和pop动画
* 2019.1.11   -- 2.1.7 解决开启左滑push功能，在根控制器多次左右滑动后出现卡死的问题
* 2018.12.2   -- 2.1.6 导航栏处理优化，可在viewDidLoad中使用gk_navLineHidden来隐藏分割线
* 2018.11.29 -- 2.1.5 修复在控制器中设置gk_backStyle无效的问题，其他细节微调
* 2018.10.28 -- 2.1.4 移除对UIVideoEditorController的控制
* 2018.10.19 -- 2.1.3 修复设置透明导航栏在iOS10以前无效的问题
* 2018.9.27   -- 2.1.1 全面适配iPhone X系列机型，修复bug
* 2018.9.11   -- 2.1.0 解决根控制器开启左滑push无效的问题
* 2018.9.10   -- 2.0.8 拆分左右间距设置属性，可分别设置导航栏左右间距
* 2018.9.7     -- 2.0.6 发布，增加设置导航栏标题和隐藏分割线的属性
* 2018.3.8     -- 2.0.1 发布，修复bug，控制器新增设置导航栏左右按钮间距的属性
* 2018.3.5     -- 2.0.0 发布，修复bug，解决崩溃问题
* 2017.10.11 -- 1.3.0 版本,   修复bug，解决手势冲突问题
* 2017.9.20   -- 1.2.6 版本  适配iOS11，iPhone X
* 2017.8.31   --
    1. 新增控制器旋转的方法，可以很好的控制单个控制器的旋转问题
    2. 新增获取当前显示的控制器的方法
* 2017.8.30   --
    1. 优化设置导航栏背景色的方法
    2. 新增隐藏和显示导航栏底部分割线的方法
* 2017.8.25   -- 新增控制器设置状态栏的方法，优化部分内容
* 2017.8.23   -- 修复图片不显示的bug
* 2017.8.18   -- 修复pod错误问题
* 2017.7.14   -- 支持cocoapods
* 2017.7.13   -- 框架实现完成，发布
