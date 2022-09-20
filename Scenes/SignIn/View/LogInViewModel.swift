//
//  LogInViewModel.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 9/18/22.
//

import Foundation
import SwiftUI
import Combine

protocol LogInViewModelInterface: ObservableObject {
    func subscribeOnLogInState()
}

class LogInViewModel: LogInViewModelInterface {
    private let store: AuthStore
    private var disposables = Set<AnyCancellable>()

    init(store: AuthStore) {
        self.store = store
    }

    func subscribeOnLogInState() {
        store
            .$state
            .receive(on: DispatchQueue.main)
            .sink { state in
                if state.isConnected {
                    Router.openMainScreen()
                }
            }
            .store(in: &disposables)
    }
}
