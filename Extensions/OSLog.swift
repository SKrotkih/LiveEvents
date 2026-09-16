//
//  OSLog.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 20.12.2022.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//
import Foundation
import os.log

extension OSLog {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.skdevappleid.liveevents"
    /// Set up CATEGORY <bundle id> and CATEGORY appstate in the search field
    static let appState = OSLog(subsystem: subsystem, category: "appstate")
}
