source 'https://github.com/CocoaPods/Specs.git'

target 'LiveEvents' do
    
    platform :ios, '13.0'
    use_frameworks!
    
    # Google Sign-In
    pod 'GoogleSignIn'
    # SwiftUI Sign in with Google button:
    pod 'GoogleSignInSwiftSupport'
    
    # Use the framework from repo:
    pod 'YTLiveStreaming'
    # But You can use the local copy just for development:
    # pod 'YTLiveStreaming', :path => '../.'

    pod "XCDYouTubeKit", "~> 2.15"
    
    pod "youtube-ios-player-helper", "~> 1.0.3"
    
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'RxDataSources'
    pod 'LFLiveKit'
    pod "PromiseKit/CorePromise", "~> 6.8"

    target 'LiveEventsTests' do
      pod 'RxTest'
      pod 'RxBlocking'
    end
end
