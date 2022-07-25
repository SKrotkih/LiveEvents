//
//  AuthReducer.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import Combine

// For more information check "How To Control The World" - Stephen Celis
// https://vimeo.com/291588126
struct World {
    var service = SignInService()
}

// Reducer: A Reducer is a function that takes the current state from the store, and the action.
// It combines the action and current state together and returns the new state
func authReducer(state: inout AuthState, action: AuthAction, environment: World) -> AnyPublisher<AuthAction, Never> {
    switch action {
    case let .signedIn(userSession):
        state.userSession = userSession
    case .loggedOut:
        state.userSession = nil
    case .logOut:
        // async operation; finished by .loggedOut sate:
        environment.service.logOut()
    case let .loggedInWithError(message):
        state.logInErrorMessage = message
    }
    return Empty().eraseToAnyPublisher()
}
