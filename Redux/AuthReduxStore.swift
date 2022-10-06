//
//  AuthReduxStore.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import Combine

typealias AuthReduxStore = Store<AuthState, AuthAction, NetworkService>
typealias Reducer<State, Action, Environment> = (inout State, Action, Environment) -> AnyPublisher<Action, Never>?

//
// Store: Store holds the state. Store receives the action and passes on to the reducer
// and gets the updated state and passes on to the subscribers.
// It is important to note that you will only have a single store in an application.
// If you want to split your data handling logic,
// you will use reducer composition i.e using many reducers instead of many stores.
//
// Example:
// private let store: AuthReduxStore = Store(initialState: .init(userSession: nil), reducer: authReducer)
//
// Thanks https://github.com/mecid/redux-like-state-container-in-swiftui for idea
final class Store<State, Action, Environment>: ObservableObject {
    @Published private(set) var state: State

    private let reducer: Reducer<State, Action, Environment>
    private let environment: Environment
    private var disposables: Set<AnyCancellable> = []

    init(
        initialState: State,
        reducer: @escaping Reducer<State, Action, Environment>,
        environment: Environment
    ) {
        self.state = initialState
        self.reducer = reducer
        self.environment = environment
    }

    func stateDispatch(action: Action) {
        guard let effect = reducer(&state, action, environment) else {
            return
        }
        effect
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: stateDispatch)
            .store(in: &disposables)
    }
}
