//
//  LogInViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 9/18/22.
//

import Foundation
import SwiftUI
import Combine

protocol LogInViewModelInterface: ObservableObject {
    var presentingViewController: UIViewController! { get set }
    var isConnected: Bool { get }
    var errorMessage: String? { get }
    func configure()
}

final class LogInViewModel: LogInViewModelInterface {
    @Published var errorMessage: String?
    @Published var isConnected: Bool = false
    var presentingViewController: UIViewController!

    private let store: AuthReduxStore
    private var disposables = Set<AnyCancellable>()

    init(store: AuthReduxStore) {
        self.store = store
    }

    func configure() {
        NewRouter.environment.service.presentingViewController = presentingViewController
        // subscribe on Log In state
        store
            .$state
            .receive(on: DispatchQueue.main)
            .sink { state in
                if state.isConnected {
                    self.errorMessage = nil
                    self.isConnected = true
                } else if let message = state.logInErrorMessage, !message.isEmpty {
                    self.errorMessage = message
                    self.isConnected = false
                } else {
                    self.errorMessage = nil
                    self.isConnected = false
                }
            }
            .store(in: &disposables)
    }
}
