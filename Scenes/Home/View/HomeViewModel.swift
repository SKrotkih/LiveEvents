//
//  HomeViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import SwiftUI
import Combine

protocol HomeViewModelObservable {
    var avatarImage: UIImage? { get set }
    var isAvatarDownloading: Bool { get set }
}

protocol HomeViewModelLaunched {
    func downloadAvatarImage(url: String)
    func logOut()
}

typealias HomeViewModelInterface = ObservableObject & HomeViewModelObservable & HomeViewModelLaunched

enum HomeViewActions {
    case videoList
    case logOut
    case nothing
}

final class HomeViewModel: HomeViewModelInterface {
    @Published var isAvatarDownloading = false
    @Published var avatarImage: UIImage?
    @Published var userName: String = ""

    @Published var actions: HomeViewActions = .nothing
    
    private var disposables = Set<AnyCancellable>()
    private let store: AuthReduxStore

    init(store: AuthReduxStore) {
        self.store = store
        
        $actions
            .sink { userActivities in
                switch userActivities {
                case .logOut:
                    self.logOut()
                case .videoList:
                    // View is hundling by itself
                    break
                case .nothing:
                    break
                }
            }.store(in: &disposables)
    }

    @MainActor
    func downloadUserName() async {
        if let userSession = await self.store.state.userSession,
           let profile = userSession.profile {
            self.userName = profile.fullName
        } else {
            self.userName = "Undefined name"
        }
    }

    func downloadAvatarImage(url: String) {
        self.isAvatarDownloading = true
        RemoteStorageData.fetch(urlData: url)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.isAvatarDownloading = false
            } receiveValue: { data in
                self.avatarImage = UIImage(data: data)
            }
            .store(in: &disposables)
    }

    func logOut() {
        store.stateDispatch(action: .logOut)
    }
}
