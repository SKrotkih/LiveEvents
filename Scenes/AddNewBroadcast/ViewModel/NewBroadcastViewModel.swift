//
//  NewBroadcastViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 11/5/22.
//
import Foundation
import YTLiveStreaming

@MainActor
final class NewBroadcastViewModel: ObservableObject {
    @Published var model = BroadcastModel()
    @Published var error = ""
    @Published private(set) var isOperationInProgress = false

    private let broadcastsAPI: YouTubeLiveClient

    init(broadcastsAPI: YouTubeLiveClient) {
        self.broadcastsAPI = broadcastsAPI
    }

    func verification() -> Bool {
        if model.title.isEmpty {
            error = "The Live Event Title is empty"
            return false
        }
        return true
    }

    /// Creates the broadcast, creates a stream and binds them — one call.
    func createNewStream() async throws {
        isOperationInProgress = true
        defer { isOperationInProgress = false }
        let (broadcast, stream) = try await broadcastsAPI.createBroadcastWithStream(
            model.createBroadcastRequest,
            stream: model.createStreamRequest
        )
        print("Scheduled '\(broadcast.snippet.title)'; ingest: \(stream.cdn?.ingestionInfo?.fullIngestionURL ?? "-")")
    }
}
