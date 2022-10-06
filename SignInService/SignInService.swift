//
//  SignInService.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit
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
    let signInPackageAPI = SwiftGoogleSignIn.packageAPI

    private let isScopesApproved = false
    @Lateinit var store: AuthReduxStore
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
        signInPackageAPI.initialize(isScopesApproved ? googleAPIscopes : nil)
        startListeningUserConnect()
    }

    func openURL(_ url: URL) -> Bool {
        return signInPackageAPI.openUrl(url)
    }

    func logOut() {
        signInPackageAPI.logOut()
    }

    var presentingViewController: UIViewController? {
        didSet {
            signInPackageAPI.presentingViewController = presentingViewController
        }
    }

    private func startListeningUserConnect() {
        signInPackageAPI.userSessionObservable?
            .receive(on: RunLoop.main)
            .sink { [weak self] session in
                self?.store.stateDispatch(action: .signedIn(userSession: session))
            }
            .store(in: &self.disposables)

        signInPackageAPI.loginResult?
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

        signInPackageAPI.logoutResult?
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
                store.stateDispatch(action: .loggedInWithError(message: message))
            case 501:
                Alert.showOkCancel(message, message: "Would you like to send request?", onComplete: {
                    self.signInPackageAPI.requestPermissions()
                })
            default:
                store.stateDispatch(action: .loggedInWithError(message: message))
            }
        case .message(let text):
            store.stateDispatch(action: .loggedInWithError(message: text))
        }
    }
}
