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

@MainActor
protocol SignInActions {
    func openURL(_ url: URL)
    func logOut()
}

@MainActor
protocol SignInPresentable {
    func setUpViewController(_ viewController: UIViewController)
}

@MainActor
protocol SignInConfigurable {
    func configure()
}

typealias NetworkProtocol = SignInPublisher & SignInActions & SignInPresentable & SignInConfigurable

///
/// Example of using the SwiftGoogleSignIn 2.0 package: the session publisher feeds the Redux
/// store, the error publisher shows the failure (or offers to request the missing scopes).
///
@MainActor
final class SignInService: NetworkProtocol, ObservableObject {
    @Published var userSession: UserSession?

    var signInAPI: SwiftGoogleSignInInterface = SwiftGoogleSignIn.API

    /// Scopes the YouTube Data API needs. The OAuth consent screen must list them
    /// (in Testing mode your account must be a test user).
    static let youtubeScopes = [
        "https://www.googleapis.com/auth/youtube",
        "https://www.googleapis.com/auth/youtube.readonly",
        "https://www.googleapis.com/auth/youtube.force-ssl"
    ]

    private var disposables = Set<AnyCancellable>()

    init() {}

    func configure() {
        signInAPI.initialize(Self.youtubeScopes)
        subscribeOnSignIn()
    }

    func openURL(_ url: URL) {
        if !signInAPI.openUrl(url) {
            Router.store.stateDispatch(action: .openUrlWithError(message: "Failed open \(url.absoluteString)"))
        }
    }

    func logOut() {
        signInAPI.logOut()
    }

    func setUpViewController(_ viewController: UIViewController) {
        signInAPI.presentingViewController = viewController
    }

    // MARK: - Private

    private func subscribeOnSignIn() {
        signInAPI.publisher
            .receive(on: RunLoop.main)
            .sink { [weak self] session in
                self?.userSession = session.isConnected ? session : nil
                if session.isConnected {
                    Router.store.stateDispatch(action: .signedIn(userSession: session))
                } else {
                    Router.store.stateDispatch(action: .loggedOut)
                }
            }
            .store(in: &disposables)

        signInAPI.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.handle(error)
            }
            .store(in: &disposables)
    }

    private func handle(_ error: SignInError) {
        switch error {
        case .cancelled:
            break   // the user closed the Google sheet; nothing to report
        case .missingScopes:
            Alert.showOkCancel(error.localizedDescription,
                               message: "Would you like to grant them now?",
                               onComplete: { [weak self] in self?.signInAPI.requestPermissions() })
        case .signOutFailed:
            print("Sign-out: \(error.localizedDescription)")   // already signed out locally
        default:
            Router.store.stateDispatch(action: .signInError(message: error.localizedDescription))
        }
    }
}
