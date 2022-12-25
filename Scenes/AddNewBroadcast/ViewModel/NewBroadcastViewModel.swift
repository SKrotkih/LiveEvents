//
//  NewBroadcastViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 11/5/22.
//
import Combine
import YTLiveStreaming

class NewBroadcastViewModel: ObservableObject {
    @Published var model = BroadcastModel()
    @Published var error = ""
    @Published var isOperationInProgress = false

    var broadcastsAPI: YTLiveStreaming!

    func verification() -> Bool {
        if model.title.isEmpty {
            error = "The Live Event Title is empty"
            return false
        } else {
            return true
        }
    }
}

// MARK: - Interactor

extension NewBroadcastViewModel {
    func createNewStream() async throws {
        await MainActor.run {
            isOperationInProgress = true
        }
        // do effect sending request. make sense in case error
        try await Task.sleep(nanoseconds: 2_000_000_000)

        let result = await withUnsafeContinuation { continuation in
            let body = PostLiveBroadcastBody(title: model.title,
                                             scheduledStartTime: model.scheduledStartTime,
                                             description: model.description,
                                             scheduledEndTime: model.scheduledEndTime,
                                             selfDeclaredMadeForKids: model.selfDeclaredMadeForKids,
                                             enableAutoStart: model.enableAutoStart,
                                             enableAutoStop: model.enableAutoStop,
                                             enableClosedCaptions: model.enableClosedCaptions,
                                             enableDvr: model.enableDvr,
                                             enableEmbed: model.enableEmbed,
                                             recordFromStart: model.recordFromStart,
                                             enableMonitorStream: model.enableMonitorStream,
                                             broadcastStreamDelayMs: model.broadcastStreamDelayMs,
                                             privacyStatus: model.privacyStatus,
                                             isReusable: model.isReusable)
            self.broadcastsAPI.createBroadcast(body,
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
