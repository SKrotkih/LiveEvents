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

    var broadcastsAPI: YouTubeLiveClient!

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
    /// Creates the broadcast, creates a stream and binds them — one call in 1.0.
    func createNewStream() async throws {
        await MainActor.run { isOperationInProgress = true }
        do {
            let (broadcast, stream) = try await broadcastsAPI.createBroadcastWithStream(
                model.createBroadcastRequest,
                stream: model.createStreamRequest
            )
            print("Scheduled '\(broadcast.snippet.title)'; ingest: \(stream.cdn?.ingestionInfo?.fullIngestionURL ?? "-")")
            await MainActor.run { isOperationInProgress = false }
        } catch {
            await MainActor.run { isOperationInProgress = false }
            throw error
        }
    }
}
