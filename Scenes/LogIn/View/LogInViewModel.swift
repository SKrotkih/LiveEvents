//
//  LogInViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 9/18/22.
//

import Foundation
import SwiftUI
import Combine

protocol LogInViewPresentable {
    var presentingViewController: UIViewController! { get set }
}

protocol LogInViewConnectable {
    func configure()
}

typealias LogInViewModelInterface = ObservableObject & LogInViewPresentable & LogInViewConnectable

final class LogInViewModel: LogInViewModelInterface {
    var presentingViewController: UIViewController!

    private let store: AuthReduxStore
    private var disposables = Set<AnyCancellable>()

    init(store: AuthReduxStore) {
        self.store = store
    }

    func configure() {
        Router.environment.service.presentingViewController = presentingViewController
    }
}
