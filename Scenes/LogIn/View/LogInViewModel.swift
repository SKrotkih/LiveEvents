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
    var isConnected: Bool { get }
    var errorMessage: String { get }
    func configure(with viewController: UIViewController)
}

final class LogInViewModel: LogInViewModelInterface {
    @Published var errorMessage: String = ""
    @Published var isConnected: Bool = false

    private let store: AuthReduxStore

    private var disposables = Set<AnyCancellable>()

    init(store: AuthReduxStore) {
        self.store = store
    }

    func configure(with viewController: UIViewController) {

        NewRouter.environment.service.presentingViewController = viewController

        // subscribe on Log In state
        store
            .$state
            .receive(on: DispatchQueue.main)
            .sink { state in
                if state.isConnected {
                    self.isConnected = true
                } else if let message = state.logInErrorMessage, !message.isEmpty {
                    self.errorMessage = message
                }
            }
            .store(in: &disposables)
    }
}
