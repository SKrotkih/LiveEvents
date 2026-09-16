//
//  LiveEventsApp.swift
//  LiveEvents
//
//  SwiftUI app lifecycle. Google Sign-In's callback URL arrives through `onOpenURL`.
//

import SwiftUI

@main
struct LiveEventsApp: App {
    private let environment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            environment.makeRootView()
                .onOpenURL { url in
                    environment.store.dispatch(.openUrl(url))
                }
        }
    }
}
