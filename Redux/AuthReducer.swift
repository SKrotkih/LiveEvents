//
//  AuthReducer.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import os.log

/// "How To Control The World" — Stephen Celis, https://vimeo.com/291588126
struct NetworkService {
    var configurator: SignInConfigurable
    var actions: SignInActions
    var presenter: SignInPresentable

    init(with service: NetworkProtocol) {
        configurator = service
        actions = service
        presenter = service
    }
}

/// Combines the current state with an action and produces the new state.
/// Side effects (sign-in SDK calls) go through the environment; their results come back as actions.
@MainActor
func authReducer(state: inout AuthState, action: AuthAction, environment: NetworkService) {
    switch action {
    case .configure:
        environment.configurator.configure()
    case .viewController(let viewController):
        environment.presenter.setUpViewController(viewController)
    case .openUrl(let url):
        environment.actions.openURL(url)
    case .signedIn(let userSession):
        state.userSession = userSession
        state.error = nil
    case .signInError(let error):
        state.userSession = nil
        state.error = error
    case .requestPermissions:
        state.error = nil
        environment.actions.requestPermissions()
    case .loggedOut:
        state.userSession = nil
        state.error = nil
    case .logOut:
        // Asynchronous; finished by `.loggedOut`.
        environment.actions.logOut()
    case .openUrlWithError(let message):
        os_log("openURL failed: %{public}@", log: .appState, type: .error, message)
    }
    os_log("appstate: The user is %{public}@", log: .appState, type: .info, state.isConnected ? "connected" : "disconnected")
}
