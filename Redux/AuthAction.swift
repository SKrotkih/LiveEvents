//
//  AuthAction.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import Combine
import SwiftGoogleSignIn

// Action: Actions are payloads or simply objects of information,
// that captures from the application via any kind of events such as
// touch events, network API responses etc,.
enum AuthAction {
    case signedIn(userSession: UserSession?)
    case logOut
    case loggedInWithError(message: String)
    case loggedOut
}
