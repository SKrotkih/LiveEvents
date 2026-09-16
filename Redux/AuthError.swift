//
//  AuthError.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation

enum AuthError: Error, Equatable, Sendable {
    /// Something to show under the sign-in button.
    case message(String)
    /// The account signed in but declined the YouTube scopes; the user can grant them again.
    case missingScopes(String)

    var message: String {
        switch self {
        case .message(let text), .missingScopes(let text):
            return text
        }
    }
}
