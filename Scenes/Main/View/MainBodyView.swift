import SwiftUI

/// Video list (home screen) or the log-in screen, depending on the sign-in state.
struct MainBodyView: View {
    @EnvironmentObject var store: AuthReduxStore

    var body: some View {
        NavigationStack {
            if store.state.isConnected {
                VideoListView()
            } else {
                LogInView()
            }
        }
    }
}
