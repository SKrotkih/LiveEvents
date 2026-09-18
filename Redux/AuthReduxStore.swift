import Combine

typealias AuthReduxStore = Store<AuthState, AuthAction, NetworkService>
typealias Reducer<State, Action, Environment> = @MainActor (inout State, Action, Environment) -> Void

///
/// Store: holds the state, receives actions, runs the reducer and publishes the new state.
/// One store per application; split logic with reducer composition, not with more stores.
///
/// Main-actor bound: SwiftUI reads `state`, the reducer touches UIKit (the presenting view controller).
/// Thanks https://github.com/mecid/redux-like-state-container-in-swiftui for the idea.
///
@MainActor
final class Store<State, Action, Environment>: ObservableObject {
    @Published private(set) var state: State

    private let reducer: Reducer<State, Action, Environment>
    private let environment: Environment

    init(initialState: State,
         reducer: @escaping Reducer<State, Action, Environment>,
         environment: Environment) {
        self.state = initialState
        self.reducer = reducer
        self.environment = environment
    }

    func dispatch(_ action: Action) {
        reducer(&state, action, environment)
    }
}
