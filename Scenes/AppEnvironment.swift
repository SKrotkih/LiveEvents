import SwiftUI
import YTLiveStreaming

/// Composition root: the Redux store, the sign-in service and the YouTube client,
/// plus the view models that are shared through the SwiftUI environment.
@MainActor
final class AppEnvironment: ObservableObject {
    let signInService: SignInService
    let store: AuthReduxStore
    let youtube: YouTubeLiveClient

    init() {
        let signInService = SignInService()
        let store = Store(initialState: AuthState(),
                          reducer: authReducer,
                          environment: NetworkService(with: signInService))
        signInService.dispatch = { [weak store] action in store?.dispatch(action) }
        self.signInService = signInService
        self.store = store
        self.youtube = YouTubeLiveClient(tokenProvider: ReduxTokenProvider(store: store))
        store.dispatch(.configure)
    }

    /// The root view with every shared object injected.
    func makeRootView() -> some View {
        let dataSource = BroadcastListFetcher(broadcastsAPI: youtube)
        let videoListViewModel = VideoListViewModel(store: store, dataSource: dataSource)
        let newBroadcastViewModel = NewBroadcastViewModel(broadcastsAPI: youtube)
        let menuViewModel = MenuViewModel(store: store)
        let logInViewModel = LogInViewModel(store: store)

        return MainBodyView()
            .environmentObject(self)
            .environmentObject(store)
            .environmentObject(menuViewModel)
            .environmentObject(logInViewModel)
            .environmentObject(videoListViewModel)
            .environmentObject(newBroadcastViewModel)
    }
}
