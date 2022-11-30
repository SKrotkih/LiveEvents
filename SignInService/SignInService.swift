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

///
/// The SwiftGoogleSignIn package adapter
/// It's an example of using the package.
/// It's listening to the package events and updating Redux store state accordingly
///
class SignInService: SignInObserver, ObservableObject {
    @Published var userSession: UserSession?
    @Lateinit var store: AuthReduxStore

    var signInAPI: SwiftGoogleSignInInterface = SwiftGoogleSignIn.API

    // There are needed sensitive scopes to have ability to work properly
    // Make sure they are presented in your app. Then send request on an verification
    private let googleAPIscopes = [
        "https://www.googleapis.com/auth/youtube",
        "https://www.googleapis.com/auth/youtube.readonly",
        "https://www.googleapis.com/auth/youtube.force-ssl"
    ]

    // My google API scopes are not approved so far!
    private let isScopesApproved = false
    private var disposables = Set<AnyCancellable>()

    func configure() {
        signInAPI.initialize(isScopesApproved ? googleAPIscopes : nil)
        subscribeOnSignedIn()
    }

    func openURL(_ url: URL) -> Bool {
        return signInAPI.openUrl(url)
    }

    func logOut() {
        signInAPI.logOut()
    }

    var presentingViewController: UIViewController? {
        didSet {
            signInAPI.presentingViewController = presentingViewController
        }
    }

    private func subscribeOnSignedIn() {
        signInAPI
            .publisher
            .receive(on: RunLoop.main)
            .sink { [weak self] session in
                guard let self else { return }
                if session.isConnected {
                    self.store.stateDispatch(action: .signedIn(userSession: session))
                } else if let error = session.error {
                    self.parse(error: error)
                } else {
                    self.store.stateDispatch(action: .loggedOut)
                }
            }
            .store(in: &self.disposables)
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
                    self.signInAPI.requestPermissions()
                })
            default:
                store.stateDispatch(action: .loggedInWithError(message: message))
            }
        case .message(let text):
            store.stateDispatch(action: .loggedInWithError(message: text))
        }
    }
}
