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
        await MainActor.run { isOperationInProgress = true }
        // do effect sending request. make sense in case error
        try await Task.sleep(nanoseconds: 2_000_000_000)
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
        do {
            let broadcast = try await self.broadcastsAPI.createBroadcastAsync(body)
            print("You have scheduled a new broadcast with title '\(broadcast.snippet.title)'")
            await MainActor.run { isOperationInProgress = false }
        } catch {
            await MainActor.run { isOperationInProgress = false }
            throw error
        }
    }
}
