//
//  NewNewStreamViewModel.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 11/5/22.
//

import Combine
import YTLiveStreaming

class NewNewStreamViewModel: ObservableObject {
    @Published var model = NewStream()
    @Published var error = ""

    var broadcastsAPI: YTLiveStreaming!

    func done() {
        switch model.verification() {
        case .success:
            createBroadcast()
        case .failure(let error):
            self.error = error.message()
        }
    }
}

// MARK: - Interactor

extension NewNewStreamViewModel {

    func createBroadcast() {
        self.broadcastsAPI.createBroadcast(model.title,
                                           description: model.description,
                                           startTime: model.startStreaming,
                                           completion: { [weak self] result in
            switch result {
            case .success(let broadcast):
                Alert.showOk("Good job!", message: "You have scheduled a new broadcast with title '\(broadcast.snippet.title)'")
                // self?.rxOperationCompleted.onNext(true)
            case .failure(let error):
                switch error {
                case .systemMessage(let code, let message):
                    let text = "\(code): \(message)"
                    Alert.showOk("Error", message: text)
                default:
                    Alert.showOk("Error", message: error.message())
                }
            }
        })
    }
}
