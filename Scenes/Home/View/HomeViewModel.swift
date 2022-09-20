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
    var isavatarDownloading: Bool { get set }
    var avatarImage: UIImage? { get set }
    func downloadImage(url: String)
}

class HomeViewModel: HomeViewModelInterface {
    @Published var isavatarDownloading = false
    @Published var avatarImage: UIImage?

    private var disposables = Set<AnyCancellable>()

    func downloadImage(url: String) {
        self.isavatarDownloading = true
        ImageLoader.fetchData(urlString: url)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.isavatarDownloading = false
            } receiveValue: { data in
                self.avatarImage = UIImage(data: data)
            }
            .store(in: &disposables)
    }
}
