//
//  SignInService.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import Combine
import SwiftGoogleSignIn

// MARK: - SignIn ViewModel Protocol

typealias SignInObserver = SignInResultObserver & UserSessionObserver

protocol SignInResultObserver {
}

protocol UserSessionObserver {
    var userSession: UserSession? { get }
}

class SignInService: SignInObserver, ObservableObject {
    let logInSession = SwiftGoogleSignIn.session

    private let isScopesApproved = false
    @Lateinit var store: AuthStore
    // There are needed sensitive scopes to have ability to work properly
    // Make sure they are presented in your app. Then send request on an verification
    private let googleAPIscopes = [
        "https://www.googleapis.com/auth/youtube",
        "https://www.googleapis.com/auth/youtube.readonly",
        "https://www.googleapis.com/auth/youtube.force-ssl"
    ]

    private var disposables = Set<AnyCancellable>()

    @Published var userSession: UserSession?

    func configure() {
        logInSession.initialize(isScopesApproved ? googleAPIscopes : nil)
        listenToUserSession()
    }

    func openURL(_ url: URL) -> Bool {
        return logInSession.openUrl(url)
    }

    func logOut() {
        logInSession.logOut()
    }

    var presentingViewController: UIViewController? {
        didSet {
            logInSession.presentingViewController = presentingViewController
        }
    }

    private func listenToUserSession() {
        logInSession.userSessionObservanle?
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.store.stateDispatch(action: .signIn(userSession: $0))
            }
            .store(in: &self.disposables)

        logInSession.loginResult?
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.parse(error: error)
                default:
                    break
                }
            }, receiveValue: { _ in
            })
            .store(in: &disposables)

        logInSession.logoutResult?
            .receive(on: DispatchQueue.main)
            .sink { result in
                if result {
                    self.store.stateDispatch(action: .loggedOut)
                }
            }
            .store(in: &disposables)
    }

    // MARK: - Private methods

    private func parse(error: SwiftError) {
        switch error {
        case .systemMessage(let code, let message):
            switch code {
            case 401:
                store.stateDispatch(action: .logInError(text: message))
            case 501:
                Alert.showOkCancel(message, message: "Would you like to send request?", onComplete: {
                    self.logInSession.requestPermissions()
                })
            default:
                store.stateDispatch(action: .logInError(text: message))
            }
        case .message(let message):
            store.stateDispatch(action: .logInError(text: message))
        }
    }
}
