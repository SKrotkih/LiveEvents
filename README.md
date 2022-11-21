[![ci](https://github.com/SKrotkih/LiveEvents/actions/workflows/main.yml/badge.svg)]

# LiveEvents

LiveEvents helps you to manage your own Youtube video in your account.  
It is an example of using [YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) and
[SwiftGoogleSignIn](https://github.com/SKrotkih/SwiftGoogleSignIn.git) Swift packages (SPM).
It uses [SwiftUI](https://developer.apple.com/documentation/SwiftUI), [Combine](https://developer.apple.com/documentation/Combine), [Concurrency (await/async)](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html), [Redux](https://en.wikipedia.org/wiki/Redux_%28JavaScript_library%29) pattern for Swift.

## Requirements

- Xcode 13+
- Swift 5.*

## Introduction

- First of all follow instructions for the [YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) Framework to create and set up Google application which uses the YouTube Data API v3.

- Download or clone the repository

- Launch console command `pod install` in the root directory   

- Open the LiveEvents.xcworkspace file in Xcode

- Update current bundle id on yours

- Rename Config.plist.example.plist (you can find it in the root directory) to Config.plist. Include it into the app main bundle. It used by SwiftGoogleSignIn package for Google signing in. Edit the Config.plist namely change client ID and API key values on yours

<img src="https://user-images.githubusercontent.com/2775621/173193901-cbdc8653-76c8-4aea-b0d9-0f9d4391fba3.png" alt="Config.plist" style="width: 690px;" />

- Open Info.plist and edit CFBundleURLSchemes key value. Change the value that starts with "com.googleusercontent.apps." based on your API key. It should be set to the reversed API key. The API key has the format XXXXXXXX.apps.googleusercontent.com and the allowed URL should be com.googleusercontent.apps.XXXXXXXX :

<img src="https://user-images.githubusercontent.com/2775621/173220142-003b05e9-3903-4959-b88a-7f1181c1c010.png" alt="Info.plist Example" style="width: 690px;" />

## The Redux pattern was used

Please pay attention on the Home and SignIn screens.

## Libraries Used

- [SwiftGoogleSignIn](https://github.com/SKrotkih/SwiftGoogleSignIn.git) package uses
[Goggle Sign-In for iOS](https://developers.google.com/identity/sign-in/ios/start-integrating).
- [YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) used as a package in current release (can be used as Cocoa Pods Framework too).

## Video
![LiveEvents Demo Video](https://user-images.githubusercontent.com/2775621/203057067-4312cba6-dd33-40dc-9fa1-d278e6ce55b9.gif)

## The 'UIKit' of the app version
In branch 'UIKit' you will find UIKit version of the app where used UIKit layout instead of SwiftUI approach. It is the previous version of the app. 

Author
Serhii Krotkykh

Changes history:
- 20-22-2022 current user session is safe now
- 20-09-2022 bug fixes. Redesign home and log in screens
- 20-07-2022 implement Redux pattern for Login scene
- 15-07-2022 added CI unit tests with Xcode Actions  
- 11-11-2016 the project was created
