import Foundation
import os.log

extension OSLog {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.skdevappleid.liveevents"
    /// Set up CATEGORY <bundle id> and CATEGORY appstate in the search field
    static let appState = OSLog(subsystem: subsystem, category: "appstate")
}
