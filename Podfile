source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

# 忽略pod警告
inhibit_all_warnings!

target 'GKWYMusic' do

  use_frameworks!
  
  pod 'ReactiveObjC'                    # 函数响应式框架
  pod 'AFNetworking'                    # 网络请求框架
  pod 'SDWebImage'                      # 图片缓存框架
  pod 'YYModel'                         # 数据解析框架
  pod 'FreeStreamer'                    # 音频播放
  pod 'GKNavigationBar'                 # 自定义导航栏
  pod 'Masonry'                         # 布局框架
  pod 'JXCategoryViewExt', :subspecs => ['Title', 'Number', 'Indicator/Line'] 
  pod 'GKCover'                         # 遮罩
  pod 'GKMessageTool'                   # 提示框
  pod 'MJRefresh'                       # 下拉刷新
  pod 'GKPageScrollView'                # UIScrollView嵌套
  pod 'JLRoutes'                        # 路由
  pod 'ZFPlayer/AVPlayer'               # 播放器
  pod 'ZFPlayer/ControlView'

end

post_install do |installer|
  # 消除版本警告
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 9.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end
end
