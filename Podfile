
target 'LiveEvents' do
    
    platform :ios, '13.0'
    use_frameworks!
    
    # clean comment if you want to use framework instead of package
    # pod 'YTLiveStreaming'
    # pod 'YTLiveStreaming', :path => '../.'

    pod "XCDYouTubeKit", "~> 2.15"
    
    pod "youtube-ios-player-helper", "~> 1.0.3"
    
    pod 'HaishinKit', '~> 1.9'
    pod "PromiseKit/CorePromise", "~> 6.8"

    target 'LiveEventsTests' do
      inherit! :search_paths
    end
end

# Xcode 15+ removed libarclite; pods that still declare iOS < 12 fail to link.
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 13.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end
