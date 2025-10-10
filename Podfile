platform :ios, "14.0"
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'        #官方仓库地址

target 'lns' do
    #pod 'pop'
    pod 'Alamofire', '4.9.1'
    pod 'AliyunOSSiOS'
    pod 'AlipaySDK-iOS'
    pod 'SnapKit'
    pod 'SDWebImage' 
    pod 'Kingfisher'
    pod 'MJRefresh'
    pod 'RITLPhotos'
    pod 'Masonry'
    pod 'RITLKit'
    #pod 'JFHeroBrowser', '1.3.2'
    #pod 'Bugly'
    pod 'MBProgressHUD'
    pod 'SDWebImageFLPlugin'
    pod 'UMCommon'
    pod 'UMDevice'
    pod 'UMAPM'
    pod 'CHIPageControl'
    pod 'MCToast','0.2.0'
    pod 'IQKeyboardManagerSwift', '6.3.0'
    pod 'ReachabilitySwift'
    pod 'WechatOpenSDK-XCFramework'
    pod 'SkeletonView'
#H5 交互
    #pod 'WebViewJavascriptBridge', '~> 6.0.3'   
    #pod 'WechatOpenSDK'
    pod 'KJTouchIdManager'
    pod 'DeviceKit'
    #pod 'Charts'
    pod 'DGCharts'
    #pod 'BRPickerView'
    pod 'SQLite.swift'
    #pod 'ShowBigImg'
    pod 'CryptoSwift'
    #pod 'VdoFramework'
    #pod 'ffmpeg-kit-ios-full-gpl' , '6.0'
#pod 'JKSwiftExtension'
    pod 'JPush'
    #pod 'SideMenu'
    pod 'AliPlayerSDK_iOS'
    #pod 'KTVHTTPCache'
 #pod 'ScreenshotPreventing',         '~> 1.4.0'   # UIKit 版

post_install do |installer|
   
   #installer.pods_project.build_configurations.each do |config|
    #config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
# 允许 Pods 在模拟器环境下同时为 Intel 与 Apple Silicon 芯片编译。
  # 之前直接排除了 arm64 架构，会导致在 Apple Silicon 模拟器上构建时找不到
  # 像 Alamofire、CryptoSwift 等 Pod 生成的模块，从而出现
  # “Unable to find module dependency” 的错误。
  # 将该设置清空即可让 Xcode 根据当前环境生成所需架构的切片。
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = ""
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    # Allow running on both Intel and Apple Silicon simulators
    # config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = ""
  end
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
  end

end

target 'ElaNaturalWidgetExtension' do

    pod 'SQLite.swift'
    pod 'Alamofire', '4.9.1'
    pod 'CryptoSwift'
end
