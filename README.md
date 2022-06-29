# LiveEvents

LiveEvents is an iOS app developed on Swift with using
[YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) framework and
[SwiftGoogleSignIn](https://github.com/SKrotkih/SwiftGoogleSignIn.git) package
and can be supposed as an example of using the package and the framework.

## Requirements

- Xcode 13+
- Swift 5.5

## Introduction

- First of all follow instructions for [YTLiveStreaming](https://github.com/SKrotkih/YTLiveStreaming) Framework to create and set up Google app for using YouTube Data API v3.

<img src="https://user-images.githubusercontent.com/2775621/80704225-e826e700-8aec-11ea-875a-7971b76e40da.png" alt="Live Events Logo" style="width: 690px;" />

- Download or clone the repository.

- Select Sample folder

- Launch  `pod install`   

- Open LiveEvents.xcworkspace.

- Change current bundle id on your

- Create Config.plist. Copy content Config.plist.example.plist into new Config.plist. Change current values of the client ID and API key on yours.  

- Put [CLIENT_ID](https://developers.google.com/identity/sign-in/ios/start-integrating#get_an_oauth_client_id) and API_KEY into the plist.info:

<img src="https://user-images.githubusercontent.com/2775621/173193901-cbdc8653-76c8-4aea-b0d9-0f9d4391fba3.png" alt="Config.plist" style="width: 690px;" />

- In Sample/Info.plist edit the CFBundleURLSchemes. Change the value that starts with "com.googleusercontent.apps." based on your API key. It should be set to the reversed API key. The API key has the format XXXXXXXX.apps.googleusercontent.com and the allowed URL should be com.googleusercontent.apps.XXXXXXXX :

<img src="https://user-images.githubusercontent.com/2775621/173220142-003b05e9-3903-4959-b88a-7f1181c1c010.png" alt="Info.plist Example" style="width: 690px;" />

## Libraries Used

- [SwiftGoogleSignIn](https://github.com/SKrotkih/SwiftGoogleSignIn.git) package

Note. Here were  used the following things:
- Goggle Sign-In for iOS ( https://developers.google.com/identity/sign-in/ios/start-integrating ) 

Author
Serhii Krotkykh

The project was created
11-11-2016

last update in June 2022
