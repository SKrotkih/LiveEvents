//
//  SignInService.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit
import Combine
import SwiftGoogleSignIn

// MARK: - NetworkProtocol

protocol SignInPublisher {
    var userSession: UserSession? { get }
}

protocol SignInActions {
    func openURL(_ url: URL)
    func logOut()
}

protocol SignInPresentable {
    func setUpViewController(_ viewController: UIViewController)
}

protocol SignInConfigurable {
    func configure()
}

typealias NetworkProtocol = SignInPublisher & SignInActions & SignInPresentable & SignInConfigurable

///
/// This is an example of using SwiftGoogleSignIn package
/// listening to the package events and update the app state with Redux
///
class SignInService: NetworkProtocol, ObservableObject {
    @Published var userSession: UserSession?

    var signInAPI: SwiftGoogleSignInInterface = SwiftGoogleSignIn.API

    // My own google API scopes are not approved so far btw!
    private let isScopesApproved = false
    private var disposables = Set<AnyCancellable>()

    func configure() {
        // There are needed sensitive scopes to have ability to work properly
        // Make sure they are presented in your app. Then send request on an verification
        let googleAPIscopes = [
            "https://www.googleapis.com/auth/youtube",
            "https://www.googleapis.com/auth/youtube.readonly",
            "https://www.googleapis.com/auth/youtube.force-ssl"
        ]
        signInAPI.initialize(isScopesApproved ? googleAPIscopes : nil)
        subscribeOnSignedIn()
    }

    func openURL(_ url: URL) {
        let result = signInAPI.openUrl(url)
        if result == false {
            Router.store.stateDispatch(action: .openUrlWithError(message: "Failed open \(url.absoluteString)"))
        }
    }

    func logOut() {
        signInAPI.logOut()
    }

    func setUpViewController(_ viewController: UIViewController) {
        presentingViewController = viewController
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
            .sink(
                receiveCompletion: { result in
                    if case let .failure(error) = result {
                        self.parse(error)
                    }},
                receiveValue: { session in
                    if session.isConnected {
                        Router.store.stateDispatch(action: .signedIn(userSession: session))
                    } else {
                        Router.store.stateDispatch(action: .loggedOut)
                    }
                }
            )
            .store(in: &self.disposables)
    }

    // MARK: - Private methods

    private func parse(_ error: SwiftError) {
        switch error {
        case .systemMessage(let code, let message):
            switch code {
            case 401:
                Router.store.stateDispatch(action: .signInError(message: message))
            case 501:
                Alert.showOkCancel(message, message: "Would you like to send request?", onComplete: {
                    self.signInAPI.requestPermissions()
                })
            default:
                Router.store.stateDispatch(action: .signInError(message: message))
            }
        case .message(let text):
            Router.store.stateDispatch(action: .signInError(message: text))
        }
    }
}
