//
//  NewStreamViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 11/5/22.
//

import Combine
import YTLiveStreaming

class NewStreamViewModel: ObservableObject {
    @Published var model = NewStream()
    @Published var error = ""
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
    func createNewStream() async throws {
        await MainActor.run {
            isOperationInProgress = true
        }
        // do effect sending request. make sense in case error
        try await Task.sleep(nanoseconds: 2_000_000_000)

        let result = await withUnsafeContinuation { continuation in
            self.broadcastsAPI.createBroadcast(model.title,
                                               description: model.description,
                                               startTime: model.startStreaming,
                                               completion: { result in
                continuation.resume(returning: result)
            })
        }
        await MainActor.run {
            isOperationInProgress = false
        }

        switch result {
        case .success(let broadcast):
            print("You have scheduled a new broadcast with title '\(broadcast.snippet.title)'")
        case .failure(let error):
            switch error {
            case .systemMessage(let code, let message):
                throw LVError.message("\(code): \(message)")
            default:
                throw LVError.message(error.message())
            }
        }
    }
}
