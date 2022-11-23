//
//  AuthState.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import SwiftGoogleSignIn

/**
 State: Based on your state you render your UI or respond in any form.
 So basically state refers to the source of truth.
 */
actor AuthState: Equatable {
    var userSession: UserSession?
    var error: AuthError?
    var isConnected: Bool {
        userSession == nil ? false : true
    }

    init(userSession: UserSession?) {
        self.userSession = userSession
    }

    func setUpNewSession(_ session: UserSession?) {
        userSession = session
    }

    func setUpError(_ error: AuthError?) {
        self.error = error
    }

    static func == (lhs: AuthState, rhs: AuthState) -> Bool {
        // TODO: How to implement async equatable protocol?
        true
    }
}
