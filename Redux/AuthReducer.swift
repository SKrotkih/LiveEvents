//
//  AuthReducer.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import Combine

///
/// For more information check "How To Control The World" - Stephen Celis
/// https://vimeo.com/291588126
///
struct NetworkService {
    var configurator: SignInConfigurable
    var actions: SignInActions
    var publisher: SignInPublisher
    var presenter: SignInPresentable

    init(with service: NetworkProtocol) {
        configurator = service
        actions = service
        publisher = service
        presenter = service
    }
}

///
/// Reducer: A Reducer is a function that takes the current state from the store, and the action.
/// It combines the action and current state together and returns the new state
///
func authReducer(state: AuthState,
                 action: AuthAction,
                 environment: NetworkService) async throws -> AuthState {
    let newState = await Task {
        switch action {
        case .configure:
            environment.configurator.configure()
        case .viewController(let viewController):
            environment.presenter.setUpViewController(viewController)
        case .openUrl(let url):
            environment.actions.openURL(url)
        case let .signedIn(userSession):
            await state.setUpNewSession(userSession)
        case let .signInError(message):
            await state.setUpError(AuthError.message(message))
        case .loggedOut:
            await state.setUpNewSession(nil)
        case .logOut:
            // async operation; finished by .loggedOut state:
            environment.actions.logOut()
        case let .openUrlWithError(message):
            print(message)
        }
        return state
    }.value

    return newState
}
