//
//  NewStreamViewModel.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 11/5/22.
//

import Combine
import YTLiveStreaming

class NewStreamViewModel: ObservableObject {
    @Published var model = NewStream()
    @Published var error = ""
    @Published var operationCompleted = false
    @Published var isAvatarDownloading = false

    var broadcastsAPI: YTLiveStreaming!

    func createNewStream() {
        switch model.verification() {
        case .success:
            createBroadcast()
        case .failure(let error):
            self.error = error.message()
        }
    }
}

// MARK: - Interactor

extension NewStreamViewModel {
    private func createBroadcast() {
        isAvatarDownloading = true
        self.broadcastsAPI.createBroadcast(model.title,
                                           description: model.description,
                                           startTime: model.startStreaming,
                                           completion: { [weak self] result in
            switch result {
            case .success(let broadcast):
                print("You have scheduled a new broadcast with title '\(broadcast.snippet.title)'")
                self?.isAvatarDownloading = false
                self?.operationCompleted = true
            case .failure(let error):
                self?.isAvatarDownloading = false
                switch error {
                case .systemMessage(let code, let message):
                    self?.error = "\(code): \(message)"
                default:
                    self?.error = error.message()
                }
            }
        })
    }
}
