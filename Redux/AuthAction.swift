//
//  AuthAction.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import SwiftGoogleSignIn

// Action: Actions are payloads or simply objects of information,
// that captures from the application via any kind of events such as
// touch events, network API responses etc,.
enum AuthAction {
    case signedIn(userSession: UserSession?)
    case loggedInWithError(message: String)
    case logOut
    case loggedOut
}
