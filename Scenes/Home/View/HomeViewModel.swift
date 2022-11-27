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

final class HomeViewModel: HomeViewModelInterface {
    @Published var isAvatarDownloading = false
    @Published var isConnected = false
    @Published var avatarImage: UIImage?
    @Published var userName: String = ""

    private var disposables = Set<AnyCancellable>()
    private let store: AuthReduxStore

    init(store: AuthReduxStore) {
        self.store = store
    }
    
    @MainActor
    func checkConnection() async {
        if let _ = await self.store.state.userSession {
            self.isConnected = true
        } else {
            self.isConnected = false
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
    
    @MainActor
    func downloadUserName() async {
        if let userSession = await self.store.state.userSession,
           let profile = userSession.profile {
            self.userName = profile.fullName
        } else {
            self.userName = "Undefined name"
        }
    }
}
