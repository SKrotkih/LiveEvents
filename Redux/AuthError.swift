//
//  AuthError.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation

enum AuthError: Error, Equatable {
    case message(String)
}

func ==(a: AuthError, b: AuthError) -> Bool {
    switch (a, b) {
    case (.message(let a), .message(let b)) where a == b: return true
    default: return false
    }
}
