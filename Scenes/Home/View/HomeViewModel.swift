//
//  HomeViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import SwiftUI
import Combine

protocol HomeViewModelObservable: ObservableObject {
    var userName: String { get }
    var avatarImage: UIImage? { get set }
    var isAvatarDownloading: Bool { get set }
}

protocol HomeViewModelLaunched: ObservableObject {
    func downloadImage(url: String)
    func logOut()
}

typealias HomeViewModelInterface = HomeViewModelObservable & HomeViewModelLaunched

final class HomeViewModel: HomeViewModelInterface {
    @Published var isAvatarDownloading = false
    @Published var avatarImage: UIImage?

    private var disposables = Set<AnyCancellable>()
    private let store: AuthReduxStore

    init(store: AuthReduxStore) {
        self.store = store
    }

    var userName: String { store.state.userSession?.profile.fullName ?? "" }

    func downloadImage(url: String) {
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
