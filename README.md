[![ci](https://github.com/SKrotkih/LiveEvents/actions/workflows/main.yml/badge.svg)]

# LiveEvents

With using this app the user can manage video from their Youtube account.  
LiveEvents is an example of using [YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) framework and
[SwiftGoogleSignIn](https://github.com/SKrotkih/SwiftGoogleSignIn.git) package.

## Requirements

- Xcode 13+
- Swift 5.*

## Introduction

- First of all follow instructions for the [YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) Framework to create and set up Google application which uses the YouTube Data API v3.

- Download or clone the repository

- Launch  `pod install` in the root directory   

- Open LiveEvents.xcworkspace

- Change current bundle id on yours

- Create Config.plist and copy content of the Config.plist.example.plist file there. Change client ID and API key on yours  

<img src="https://user-images.githubusercontent.com/2775621/173193901-cbdc8653-76c8-4aea-b0d9-0f9d4391fba3.png" alt="Config.plist" style="width: 690px;" />

- Open Info.plist and edit CFBundleURLSchemes key value. Change the value that starts with "com.googleusercontent.apps." based on your API key. It should be set to the reversed API key. The API key has the format XXXXXXXX.apps.googleusercontent.com and the allowed URL should be com.googleusercontent.apps.XXXXXXXX :

<img src="https://user-images.githubusercontent.com/2775621/173220142-003b05e9-3903-4959-b88a-7f1181c1c010.png" alt="Info.plist Example" style="width: 690px;" />

## Redux pattern used

The pattern was used for the app's Home and SignIn scenes.

## Libraries Used

- [SwiftGoogleSignIn](https://github.com/SKrotkih/SwiftGoogleSignIn.git) package. It uses
[Goggle Sign-In for iOS](https://developers.google.com/identity/sign-in/ios/start-integrating).
- [YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) It can be used as a package and as a Cocoa Pods Framework. In current it used as a package.

## Video
[Video of an one of the old version](https://youtu.be/HwYbvUU2fJo)

Author
Serhii Krotkykh

Changes history:
- 20-07-2022 implement Redux pattern for Login scene
- 15-07-2022 added CI unit tests with Xcode Actions  
- 11-11-2016 the project was created
