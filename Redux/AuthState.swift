//
//  AuthState.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import SwiftGoogleSignIn

/// The single source of truth for the sign-in screen: who is signed in and the last error.
struct AuthState: Equatable, Sendable {
    var userSession: UserSession?
    var error: AuthError?

    var isConnected: Bool { userSession?.isConnected ?? false }
}
