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
actor AuthState: Equatable {
    static func == (lhs: AuthState, rhs: AuthState) -> Bool {
        true
    }
    var isConnected: Bool {
        userSession == nil ? false : true
    }

    var userSession: UserSession?
    
    func setUpNewSession(_ session: UserSession?) {
        userSession = session
    }

    var error: AuthError?

    func setUpError(_ error: AuthError?) {
        self.error = error
    }
    
    init(userSession: UserSession?) {
        self.userSession = userSession
    }
}
