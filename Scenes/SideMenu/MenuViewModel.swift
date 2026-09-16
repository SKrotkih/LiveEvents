//
//  MenuViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import Combine

enum HomeViewActions {
    case videoList
    case logOut
    case nothing
}

@MainActor
final class MenuViewModel: ObservableObject {
    @Published var actions: HomeViewActions = .nothing

    private var cancellables = Set<AnyCancellable>()
    private let store: AuthReduxStore

    init(store: AuthReduxStore) {
        self.store = store
        $actions
            .sink { [weak self] action in
                if case .logOut = action { self?.logOut() }
            }
            .store(in: &cancellables)
    }

    var userName: String {
        store.state.userSession?.profile?.fullName ?? "Undefined name"
    }

    var profilePicUrl: URL? {
        store.state.userSession?.profile?.profilePicUrl
    }

    func logOut() {
        store.dispatch(.logOut)
    }
}
