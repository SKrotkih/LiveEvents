//
//  HomeViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import SwiftUI
import Combine

protocol HomeViewModelInterface: ObservableObject {
    var userName: String { get }
    var avatarImage: UIImage? { get set }
    func downloadImage(url: String)
    var isAvatarDownloading: Bool { get set }
    func logOut()
    func showVideoList()
}

class HomeViewModel: HomeViewModelInterface {
    @Published var isAvatarDownloading = false
    @Published var avatarImage: UIImage?

    private var disposables = Set<AnyCancellable>()
    private let store: AuthStore

    init(store: AuthStore) {
        self.store = store
    }

    var userName: String { store.state.userSession?.profile.fullName ?? "" }

    func downloadImage(url: String) {
        self.isAvatarDownloading = true
        ImageLoader.fetchData(urlString: url)
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
    
    func showVideoList() {
        Router.openVideoListScreen()
    }
}
