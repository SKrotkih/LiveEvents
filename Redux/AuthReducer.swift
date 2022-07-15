//
//  AuthReducer.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import Combine

// Reducer: A Reducer is a function that takes the current state from the store, and the action.
// It combines the action and current state together and returns the new state
func authReducer(state: inout AuthState, action: AuthAction, environment: SignInService) -> AnyPublisher<AuthAction, Never> {
    switch action {
    case let .signIn(userSession):
        state.userSession = userSession
    case .loggedOut:
        state.userSession = nil
    case .logOut:
        // async operation:
        environment.logOut()
    case let .logInError(text):
        state.logInErrorMessage = text
    }
    return Empty().eraseToAnyPublisher()
}
