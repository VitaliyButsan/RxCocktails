# Uncomment the next line to define a global platform for your project
# platform :ios, '11.0'

target 'RxCocktails' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for RxCocktails

  pod 'RxSwift', '5.0.0'
  pod 'RxCocoa', '5.0.0'
  pod 'RxDataSources', '~> 4.0'
  pod 'Moya/RxSwift', '~> 14.0'
  pod 'SnapKit', '~> 5.0.0'
  pod 'MBProgressHUD', '~> 1.2.0'
  pod 'SDWebImage'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
