//
//  AuthAction.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit
import SwiftGoogleSignIn

///
/// Action: Actions are payloads or simply objects of information,
/// that captures from the application via any kind of events such as
/// touch events, network API responses etc,.
///
enum AuthAction {
    case configure
    case viewController(UIViewController)
    case signedIn(userSession: UserSession?)
    case signInError(message: String)
    case logOut
    case loggedOut
    case openUrl(URL)
    case openUrlWithError(message: String)
}
