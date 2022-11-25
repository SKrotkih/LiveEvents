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
    var service = SignInService()
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
        case let .signedIn(userSession):
            await state.setUpNewSession(userSession)
        case .loggedOut:
            await state.setUpNewSession(nil)
        case .logOut:
            // async operation; finished by .loggedOut state:
            environment.service.logOut()
        case let .loggedInWithError(message):
            await state.setUpError(AuthError.message(message))
        }
        return state
    }.value

    return newState
}
