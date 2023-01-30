//
//  LogInViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 9/18/22.
//
import Foundation
import Combine

final class LogInViewModel: ObservableObject {
    private let store: AuthReduxStore

    init(store: AuthReduxStore) {
        self.store = store
    }

    func configure(with viewController: UIViewController) {
        store.stateDispatch(action: .viewController(viewController))
    }
}
