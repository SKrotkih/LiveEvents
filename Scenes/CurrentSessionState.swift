//
//  CurrentSessionState.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 20.11.2022.
//
import SwiftUI
import Combine

///
/// Current user session state safe observable object
///
@MainActor final class CurrentSessionState: ObservableObject {
    @Published private(set) var isConnected = false
    @Published private(set) var errorMessage: String?
    @ObservedObject var store: AuthReduxStore = Router.store
    private var disposables = Set<AnyCancellable>()
    
    init() {
        listeningToState()
    }
    
    private func listeningToState() {
        store.$state
            .sink { state in
                Task { @MainActor in
                    let userSession = await state.userSession
                    let logInError = await state.error
                    switch (userSession, logInError) {
                    case (.some(_) , .none):
                        self.errorMessage = nil
                        self.isConnected = true
                    case (.none, .some(_)):
                        switch logInError! {
                        case .message(let text):
                            self.errorMessage = text
                        }
                        self.isConnected = false
                    default:
                        self.errorMessage = nil
                        self.isConnected = false
                    }
                }
            }
            .store(in: &disposables)
    }
}
