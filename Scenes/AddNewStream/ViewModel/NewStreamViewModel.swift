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
        if model.title.isEmpty {
            error = "The Live Event Title is empty"
            return false
        } else if startStreaming <= Date() {
            error = "Start Live Event time is wrong"
            return false
        } else {
            return true
        }
    }
    
    private var startStreaming: Date {
        let h = model.hours.isEmpty ? 0 : Int(model.hours) ?? 0
        let m = model.minutes.isEmpty ? 0 : Int(model.minutes) ?? 0
        let s = model.seconds.isEmpty ? 0 : Int(model.seconds) ?? 0
        if h + m + s > 0 {
            return Date().add(hours: h > 24 ? 0 : h, minutes: m > 60 ? 0 : m, seconds: s > 60 ? 0 : s)
        } else {
            return model.date
        }
    }

    var runAt: String {
        startStreaming.streamDateFormat
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
                                               startTime: startStreaming,
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
