//
//  CurrentSessionState.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 20.11.2022.
//
import SwiftUI
import Combine

/**
 Current user session state safe observable object
 */
@MainActor final class CurrentSessionState: ObservableObject {
    @Published private(set) var isConnected = false
    @Published private(set) var errorMessage: String?
    @ObservedObject var store: AuthReduxStore = Router.store
    private var disposables = Set<AnyCancellable>()
    
    init() {
        startListeningToState()
    }
    
    private func startListeningToState() {
        store.$state
            .sink { state in
                Task {
                    let userSession = await state.userSession
                    let logInError = await state.error
                    if userSession != nil {
                        await MainActor.run {
                            self.errorMessage = nil
                            self.isConnected = true
                        }
                    } else if let logInError {
                        await MainActor.run {
                            switch logInError {
                            case .message(let text):
                                self.errorMessage = text
                            }
                            self.isConnected = false
                        }
                    } else {
                        await MainActor.run {
                            self.errorMessage = nil
                            self.isConnected = false
                        }
                    }
                }
            }
            .store(in: &disposables)
    }
}
