import UIKit

@MainActor
final class LogInViewModel: ObservableObject {
    private let store: AuthReduxStore

    init(store: AuthReduxStore) {
        self.store = store
    }

    /// Google Sign-In needs a view controller to present its sheet from.
    func configurePresenter() {
        if let top = UIApplication.shared.topViewController {
            store.dispatch(.viewController(top))
        }
    }

    func requestPermissions() {
        store.dispatch(.requestPermissions)
    }

    func dismissError() {
        store.dispatch(.loggedOut)
    }
}
