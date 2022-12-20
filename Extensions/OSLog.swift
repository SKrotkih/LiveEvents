//
//  OSLog.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 20.12.2022.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//
import Foundation
import os.log

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    /// Set up CATEGORY <bundle id> and CATEGORY appstate in the search field
    static let appState = OSLog(subsystem: subsystem, category: "appstate")
}
