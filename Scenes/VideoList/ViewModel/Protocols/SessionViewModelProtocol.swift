//
//  SessionViewModelProtocol.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 27.10.2020.
//  Copyright © 2020 Serhii Krotkykh. All rights reserved.
//

import Foundation
import Combine

protocol SessionManager {
    /// Observable data lets know that the user is signed out. Combine based way
    ///
    /// - Parameters:
    ///
    /// - Returns:
    var logoutResult: PassthroughSubject<Bool, Never>? { get }

    /// The user wants to sign out
    ///
    /// - Parameters:
    ///
    /// - Returns:
    func logOut()
}
