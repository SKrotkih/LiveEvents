//
//  AuthState.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import SwiftGoogleSignIn

// State: Based on your state you render your UI or respond in any form.
// So basically state refers to the source of truth.
struct AuthState: Equatable {
    var isConnected = false

    var userSession: UserSession? {
        didSet {
            isConnected = userSession != nil
        }
    }

    var logInErrorMessage: String?

    init(userSession: UserSession?) {
        self.userSession = userSession
    }
}
