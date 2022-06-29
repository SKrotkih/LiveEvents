//
//  GoogleSessionManager.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit
import Combine
import SwiftGoogleSignIn

class GoogleSessionManager: SessionManager {
    var logoutResult: PassthroughSubject<Bool, Never>? {
        return LogInSession.logoutResult
    }

    func logOut() {
        LogInSession.logOut()
    }
}
