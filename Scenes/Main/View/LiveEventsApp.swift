//
//  LiveEventsApp.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI

@main
struct LiveEvents: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            MainBodyView()
                .environmentObject(NewRouter.store)
        }
    }
}
