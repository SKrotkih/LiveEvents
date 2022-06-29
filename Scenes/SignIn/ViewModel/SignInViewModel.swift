//
//  SignInViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import Combine
import SwiftGoogleSignIn

// MARK: - SignIn ViewModel Protocol

typealias SignInViewModel = SignInInOutput & UserObserver
let LogInSession = SwiftGoogleSignIn.session

protocol SignInInOutput {
    func signInResultListener()
}

protocol UserObserver {
    var user: GoogleUser? { get }
}

class GoogleSignInViewModel: SignInViewModel, ObservableObject {
    private var cancellableBag = Set<AnyCancellable>()

    @Published var user: GoogleUser?

    func configure() {
        suscribeOnUser()
        signInResultListener()
    }

    private func suscribeOnUser() {
        LogInSession.user?
            .receive(on: RunLoop.main)
            .sink { [unowned self] in
                self.user = $0
            }
            .store(in: &self.cancellableBag)
    }

    // MARK: - SignInInOutput

    func signInResultListener() {
        LogInSession.loginResult?
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.parse(error: error)
                default:
                    break
                }
            }, receiveValue: { theUserIsLoggedIn in
                if theUserIsLoggedIn {
                    Router.showVideoListScreen()
                }
            })
            .store(in: &cancellableBag)
    }

    // MARK: - Private methods

    private func parse(_ result: Result<Void, SwiftError>) {
        switch result {
        case .success:
            Router.showVideoListScreen()
        case .failure(let error):
            // in case we get error return to the signin screen
            LogInSession.disconnect()
            parse(error: error)
        }
    }

    private func parse(error: SwiftError) {
        switch error {
        case .systemMessage(let code, let message):
            switch code {
            case 401:
                print(message)
            case 501:
                Alert.showOkCancel(message, message: "Do you want to send request?", onComplete: {
                    LogInSession.requestPermissions()
                })
            default:
                Alert.showOk("", message: message)
            }
        case .message(let message):
            Alert.showOk("", message: message)
        }
    }
}
