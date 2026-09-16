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

@MainActor protocol SignInActions {
    func openURL(_ url: URL)
    func logOut()
    func requestPermissions()
}

@MainActor protocol SignInPresentable {
    func setUpViewController(_ viewController: UIViewController)
}

@MainActor protocol SignInConfigurable {
    func configure()
}

typealias NetworkProtocol = SignInActions & SignInPresentable & SignInConfigurable

///
/// Example of using the SwiftGoogleSignIn 2.0 package: the session publisher and the error
/// publisher are turned into Redux actions.
///
@MainActor
final class SignInService: NetworkProtocol {
    /// Set by the composition root; every package event becomes an action.
    var dispatch: (@MainActor (AuthAction) -> Void)?

    private let signInAPI: SwiftGoogleSignInInterface = SwiftGoogleSignIn.API

    /// Scopes the YouTube Data API needs. The OAuth consent screen must list them
    /// (in Testing mode your account must be a test user).
    static let youtubeScopes = [
        "https://www.googleapis.com/auth/youtube",
        "https://www.googleapis.com/auth/youtube.readonly",
        "https://www.googleapis.com/auth/youtube.force-ssl"
    ]

    private var cancellables = Set<AnyCancellable>()

    init() {}

    func configure() {
        signInAPI.initialize(Self.youtubeScopes)
        subscribeOnSignIn()
    }

    func openURL(_ url: URL) {
        if !signInAPI.openUrl(url) {
            dispatch?(.openUrlWithError(message: "Failed open \(url.absoluteString)"))
        }
    }

    func logOut() {
        signInAPI.logOut()
    }

    func requestPermissions() {
        signInAPI.requestPermissions()
    }

    func setUpViewController(_ viewController: UIViewController) {
        signInAPI.presentingViewController = viewController
    }

    // MARK: - Private

    private func subscribeOnSignIn() {
        signInAPI.publisher
            .receive(on: RunLoop.main)
            .sink { [weak self] session in
                if session.isConnected {
                    self?.dispatch?(.signedIn(userSession: session))
                } else {
                    self?.dispatch?(.loggedOut)
                }
            }
            .store(in: &cancellables)

        signInAPI.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.handle(error)
            }
            .store(in: &cancellables)
    }

    private func handle(_ error: SignInError) {
        switch error {
        case .cancelled:
            break   // the user closed the Google sheet; nothing to report
        case .missingScopes:
            dispatch?(.signInError(.missingScopes(error.localizedDescription)))
        case .signOutFailed:
            print("Sign-out: \(error.localizedDescription)")   // already signed out locally
        default:
            dispatch?(.signInError(.message(error.localizedDescription)))
        }
    }
}
