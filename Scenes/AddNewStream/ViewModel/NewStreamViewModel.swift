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
    @Published var isOperationCompleted = false
    @Published var isOperationInProgress = false

    var broadcastsAPI: YTLiveStreaming!

    func verification() -> Bool {
        switch model.verification() {
        case .success:
            return true
        case .failure(let error):
            self.error = error.message()
            return false
        }
    }
}

// MARK: - Interactor

extension NewStreamViewModel {
    func createNewStream(_ completion: @escaping () -> Void) {
        isOperationInProgress = true
        self.broadcastsAPI.createBroadcast(model.title,
                                           description: model.description,
                                           startTime: model.startStreaming,
                                           completion: { [weak self] result in
            switch result {
            case .success(let broadcast):
                print("You have scheduled a new broadcast with title '\(broadcast.snippet.title)'")
                self?.isOperationInProgress = false
                self?.isOperationCompleted = true
                completion()
            case .failure(let error):
                self?.isOperationInProgress = false
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
