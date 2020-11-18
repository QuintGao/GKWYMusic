source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

# 忽略pod警告
inhibit_all_warnings!

target 'GKWYMusic' do

  use_frameworks!

  pod 'GKNavigationBarViewController'   # 自定义导航栏
#  pod 'TXLiteAVSDK_Player'              # 腾讯音视频播放
  pod 'FreeStreamer'                    # 音频播放
  pod 'AFNetworking'                    # 网络请求框架
  pod 'SDWebImage'                      # 图片缓存框架
  pod 'YYModel'                         # 数据解析框架
  pod 'GKCover'                         # 遮罩
  pod 'Masonry'                         # 布局框架
  pod 'GKMessageTool'                   # 提示框
  pod 'WMPageController'                # 分页控制框架
  pod 'MJRefresh'                       # 下拉刷新
  pod 'GKPageScrollView'

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
