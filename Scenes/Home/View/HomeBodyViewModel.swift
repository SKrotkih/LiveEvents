//
//  HomeBodyViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import SwiftUI
import Combine

class HomeBodyViewModel: ObservableObject {
    @Published var isavatarDownloading = false
    @Published var avatarImave: UIImage?

    private var disposables = Set<AnyCancellable>()

    func downloadImage(url: String) {
        self.isavatarDownloading = true
        ImageLoader.fetchData(urlString: url)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.isavatarDownloading = false
            } receiveValue: { data in
                self.avatarImave = UIImage(data: data)
            }
            .store(in: &disposables)
    }
}
