//
//  SignInAppDelegate.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit
import SwiftGoogleSignIn

class SignInAppDelegate: NSObject, UIApplicationDelegate {

    // There are needed sensitive scopes to have ability to work properly
    // Make sure they are presented in your app. Then send request on an verification
    private let googleAPIscopes = [
        "https://www.googleapis.com/auth/youtube",
        "https://www.googleapis.com/auth/youtube.readonly",
        "https://www.googleapis.com/auth/youtube.force-ssl"
    ]

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SwiftGoogleSignIn.session.initialize(googleAPIscopes)
        return true
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return SwiftGoogleSignIn.session.openUrl(url)
    }
}
