platform :ios, "15.0"
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
    pod 'AliPlayerSDK_iOS', '7.8.0'
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
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    # Allow running on both Intel and Apple Silicon simulators
    # config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = ""
  end
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end

  # AliPlayerSDK_iOS 7.8.0 ships iPhoneOS-only binaries. Keep it for real
  # devices, but remove it from the shared Pods-lns settings so simulator
  # builds can use Swift stubs without linking device-only frameworks.
  ['debug', 'release'].each do |configuration|
    xcconfig_path = File.join(
      installer.sandbox.root.to_s,
      'Target Support Files',
      'Pods-lns',
      "Pods-lns.#{configuration}.xcconfig"
    )
    next unless File.exist?(xcconfig_path)

    lines = File.readlines(xcconfig_path)
    lines.reject! { |line| line.start_with?('EXCLUDED_ARCHS[sdk=iphonesimulator*] = ') }
    lines.reject! { |line| line.start_with?('FRAMEWORK_SEARCH_PATHS[sdk=iphonesimulator*] = ') }
    lines.reject! { |line| line.start_with?('FRAMEWORK_SEARCH_PATHS[sdk=iphoneos*] = ') }
    lines.reject! { |line| line.start_with?('OTHER_LDFLAGS[sdk=iphonesimulator*] = ') }
    lines.reject! { |line| line.start_with?('OTHER_LDFLAGS[sdk=iphoneos*] = ') }
    lines.reject! { |line| line.start_with?('OTHER_MODULE_VERIFIER_FLAGS[sdk=iphonesimulator*] = ') }
    lines.reject! { |line| line.start_with?('OTHER_MODULE_VERIFIER_FLAGS[sdk=iphoneos*] = ') }

    replacements = {
      'FRAMEWORK_SEARCH_PATHS' => ->(value) {
        value
          .gsub(/\s*"\$\{PODS_ROOT\}\/AliPlayerSDK_iOS"/, '')
          .gsub(/\s*"\$\{PODS_ROOT\}\/UMAPM\/UMAPM_1\.9\.1"/, '')
      },
      'OTHER_LDFLAGS' => ->(value) {
        value.gsub(/\s*-framework "(AliyunMediaDownloader|AliyunPlayer|alivcffmpeg|UMAPM)"/, '')
      },
      'OTHER_MODULE_VERIFIER_FLAGS' => ->(value) {
        value
          .gsub(/\s*"-F\$\{PODS_CONFIGURATION_BUILD_DIR\}\/AliPlayerSDK_iOS"/, '')
          .gsub(/\s*"-F\$\{PODS_CONFIGURATION_BUILD_DIR\}\/UMAPM"/, '')
      }
    }

    lines.map! do |line|
      key, cleaner = replacements.find { |candidate, _| line.start_with?("#{candidate} = ") }
      next line unless key

      value = line.sub(/^#{Regexp.escape(key)} = /, '').strip
      "#{key} = #{cleaner.call(value)}\n"
    end

    lines << "\n"
    lines << "EXCLUDED_ARCHS[sdk=iphonesimulator*] =\n"
    lines << 'FRAMEWORK_SEARCH_PATHS[sdk=iphoneos*] = $(inherited) "${PODS_ROOT}/AliPlayerSDK_iOS" "${PODS_ROOT}/UMAPM/UMAPM_1.9.1"' << "\n"
    lines << 'OTHER_LDFLAGS[sdk=iphoneos*] = $(inherited) -framework "AliyunMediaDownloader" -framework "AliyunPlayer" -framework "alivcffmpeg" -framework "UMAPM"' << "\n"
    lines << 'OTHER_MODULE_VERIFIER_FLAGS[sdk=iphoneos*] = $(inherited) "-F${PODS_CONFIGURATION_BUILD_DIR}/AliPlayerSDK_iOS" "-F${PODS_CONFIGURATION_BUILD_DIR}/UMAPM"' << "\n"

    File.write(xcconfig_path, lines.join)
  end

  frameworks_script = File.join(
    installer.sandbox.root.to_s,
    'Target Support Files',
    'Pods-lns',
    'Pods-lns-frameworks.sh'
  )
  if File.exist?(frameworks_script)
    device_only_frameworks = [
      '${PODS_ROOT}/AliPlayerSDK_iOS/AliyunPlayer.framework',
      '${PODS_ROOT}/AliPlayerSDK_iOS/alivcffmpeg.framework',
      '${PODS_ROOT}/AliPlayerSDK_iOS/AliyunMediaDownloader.framework',
      '${PODS_ROOT}/UMAPM/UMAPM_1.9.1/UMAPM.framework'
    ]

    script_lines = File.readlines(frameworks_script)
    script_lines.map! do |line|
      next line unless device_only_frameworks.any? { |framework| line.include?(framework) }
      next line if line.include?('PLATFORM_NAME')

      "  if [ \"${PLATFORM_NAME}\" != \"iphonesimulator\" ]; then\n#{line}  fi\n"
    end
    File.write(frameworks_script, script_lines.join)
  end
  end

end

target 'ElaNaturalWidgetExtension' do

    pod 'SQLite.swift'
    pod 'Alamofire', '4.9.1'
    pod 'CryptoSwift'
end
