import SwiftUI

@main
struct LiveEventsApp: App {
    @StateObject private var environment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            environment.makeRootView()
                .onOpenURL { url in
                    environment.store.dispatch(.openUrl(url))
                }
        }
    }
}
