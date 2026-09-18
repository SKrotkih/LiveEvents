import Foundation
import YTLiveStreaming

/// Drives one live broadcast: fetches the RTMP URL, watches the broadcast with
/// `monitor(broadcastID:)` and streams the live chat. UI-facing state is published for SwiftUI.
@MainActor
final class LiveStreamingViewModel: ObservableObject {
    @Published private(set) var statusText = "Ready"
    @Published private(set) var chatLines: [String] = []
    @Published var errorMessage: String?
    @Published private(set) var isFinished = false

    private let broadcast: LiveBroadcastStreamModel
    private let broadcastsAPI: YouTubeLiveClient
    private let maxChatLines = 6

    private var monitorTask: Task<Void, Never>?
    private var chatTask: Task<Void, Never>?

    init(broadcast: LiveBroadcastStreamModel, broadcastsAPI: YouTubeLiveClient) {
        self.broadcast = broadcast
        self.broadcastsAPI = broadcastsAPI
    }

    deinit {
        monitorTask?.cancel()
        chatTask?.cancel()
    }

    /// Returns the RTMP ingestion URL and starts monitoring; `nil` on error (reported via `errorMessage`).
    func startPublishing() async -> String? {
        guard let streamID = broadcast.contentDetails?.boundStreamId, !streamID.isEmpty else {
            errorMessage = "The broadcast has no bound stream. Create it with a stream first."
            return nil
        }
        do {
            let stream = try await broadcastsAPI.stream(id: streamID)
            guard let ingestion = stream.cdn?.ingestionInfo else {
                errorMessage = "YouTube returned a stream without ingestion info"
                return nil
            }
            startMonitoring()
            return ingestion.fullIngestionURL
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    /// Ends the broadcast (`complete` is final on YouTube).
    func finishPublishing() {
        stopTasks()
        Task {
            do {
                try await broadcastsAPI.transition(broadcastID: broadcast.id, to: .complete)
            } catch {
                errorMessage = "System detected error while finishing the video.\n\(error.localizedDescription)"
            }
            isFinished = true
        }
    }

    /// User cancelled before going live: delete the scheduled broadcast.
    func cancelPublishing() {
        stopTasks()
        Task {
            do {
                try await broadcastsAPI.deleteBroadcast(id: broadcast.id)
            } catch {
                errorMessage = "System detected error while deleting the video.\n\(error.localizedDescription)\nTry to delete it in your YouTube account"
            }
            isFinished = true
        }
    }

    func report(encoderState state: PublishingState) {
        switch state {
        case .connecting: statusText = "connecting to YouTube…"
        case .publishing: statusText = "sending video, waiting for YouTube…"
        case .failed(let code): errorMessage = "Encoder error: \(code)"
        case .idle, .stopped: break
        }
    }

    // MARK: - Private

    private func stopTasks() {
        monitorTask?.cancel()
        chatTask?.cancel()
    }

    private func startMonitoring() {
        monitorTask?.cancel()
        monitorTask = Task { [weak self, broadcastsAPI, broadcast] in
            do {
                for try await event in broadcastsAPI.monitor(broadcastID: broadcast.id) {
                    guard let self else { return }
                    switch event {
                    case .snapshot(let s):
                        self.statusText = "status: \(s.lifeCycleStatus.rawValue) [\(s.streamStatus.rawValue);\(s.streamHealth.rawValue)]"
                    case .encoderConnected:
                        self.statusText = "encoder connected, going live…"
                    case .live:
                        self.statusText = "● LIVE"
                        self.startChat()
                    case .transitionFailed(_, let error):
                        self.statusText = error.apiError?.reason ?? error.localizedDescription
                    case .ended(let status):
                        self.statusText = "ended (\(status.rawValue))"
                    case .transitionRequested, .testing, .pollFailed:
                        break
                    }
                }
            } catch is CancellationError {
            } catch {
                self?.errorMessage = error.localizedDescription
            }
        }
    }

    private func startChat() {
        guard chatTask == nil, let chatID = broadcast.snippet.liveChatId else { return }
        chatTask = Task { [weak self, broadcastsAPI] in
            do {
                for try await batch in broadcastsAPI.chatMessageStream(liveChatId: chatID) {
                    guard let self else { return }
                    for message in batch where !message.text.isEmpty {
                        self.chatLines.append("\(message.authorName): \(message.text)")
                    }
                    self.chatLines = Array(self.chatLines.suffix(self.maxChatLines))
                }
            } catch is CancellationError {
            } catch {
                self?.statusText = "chat: \(error.localizedDescription)"
            }
        }
    }
}
