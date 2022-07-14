# LiveEvents

LiveEvents is an example of using [YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) framework and
[SwiftGoogleSignIn](https://github.com/SKrotkih/SwiftGoogleSignIn.git) package.

## Requirements

- Xcode 13+
- Swift 5.*

## Introduction

- First of all follow instructions for the [YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) Framework to create and set up Google application which uses the YouTube Data API v3.

- Download or clone the repository

- Launch  `pod install` in teh rood directory   

- Open LiveEvents.xcworkspace

- Change current bundle id on yours

- Create Config.plist and copy content of the Config.plist.example.plist file there. Change client ID and API key on yours  

<img src="https://user-images.githubusercontent.com/2775621/173193901-cbdc8653-76c8-4aea-b0d9-0f9d4391fba3.png" alt="Config.plist" style="width: 690px;" />

- Open Info.plist and edit CFBundleURLSchemes key value. Change the value that starts with "com.googleusercontent.apps." based on your API key. It should be set to the reversed API key. The API key has the format XXXXXXXX.apps.googleusercontent.com and the allowed URL should be com.googleusercontent.apps.XXXXXXXX :

<img src="https://user-images.githubusercontent.com/2775621/173220142-003b05e9-3903-4959-b88a-7f1181c1c010.png" alt="Info.plist Example" style="width: 690px;" />

## Libraries Used

- [SwiftGoogleSignIn](https://github.com/SKrotkih/SwiftGoogleSignIn.git) package. It used 
[Goggle Sign-In for iOS](https://developers.google.com/identity/sign-in/ios/start-integrating).  

Author
Serhii Krotkykh

The project was created
11-11-2016

last update in June 2022
