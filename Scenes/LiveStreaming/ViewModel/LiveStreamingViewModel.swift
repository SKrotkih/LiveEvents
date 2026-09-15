//
//  LiveStreamingViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import Combine
import YTLiveStreaming

final class LiveStreamingViewModel: YouTubeLiveVideoPublisher {
    // Dependencies
    @Lateinit var broadcastsAPI: YouTubeLiveClient
    /// The broadcast to stream to; injected by AppRouter before the screen is shown.
    var liveBroadcast: LiveBroadcastStreamModel?

    private let didFinishSubject = PassthroughSubject<Void, Never>()
    private let stateSubject = PassthroughSubject<String, Never>()
    private let errorSubject = PassthroughSubject<String, Never>()
    private let chatSubject = PassthroughSubject<[LiveChatMessage], Never>()

    var didFinish: AnyPublisher<Void, Never> { didFinishSubject.eraseToAnyPublisher() }
    var stateDescription: AnyPublisher<String, Never> { stateSubject.eraseToAnyPublisher() }
    var errorMessage: AnyPublisher<String, Never> { errorSubject.eraseToAnyPublisher() }
    var chatMessages: AnyPublisher<[LiveChatMessage], Never> { chatSubject.eraseToAnyPublisher() }

    /// Polls YouTube and takes the broadcast live once the encoder is sending.
    private var monitorTask: Task<Void, Never>?
    /// Streams live-chat messages while the broadcast is on air.
    private var chatTask: Task<Void, Never>?

    deinit {
        monitorTask?.cancel()
        chatTask?.cancel()
    }

    // MARK: - YouTubeLiveVideoPublisher

    func willStartPublishing() async -> (String?, Date?) {
        guard let broadcast = liveBroadcast else {
            errorSubject.send("Need a broadcast object to start live video!")
            return (nil, nil)
        }
        guard let streamID = broadcast.contentDetails?.boundStreamId, !streamID.isEmpty else {
            errorSubject.send("The broadcast has no bound stream. Create it with a stream first.")
            return (nil, nil)
        }
        do {
            let stream = try await broadcastsAPI.stream(id: streamID)
            guard let ingestion = stream.cdn?.ingestionInfo else {
                errorSubject.send("YouTube returned a stream without ingestion info")
                return (nil, nil)
            }
            startMonitoring(broadcastID: broadcast.id)
            return (ingestion.fullIngestionURL, broadcast.snippet.scheduledStartTime ?? Date())
        } catch {
            errorSubject.send(error.localizedDescription)
            return (nil, nil)
        }
    }

    func finishPublishing() {
        stopTasks()
        guard let broadcast = liveBroadcast else {
            didFinishSubject.send()
            return
        }
        Task {
            do {
                try await broadcastsAPI.transition(broadcastID: broadcast.id, to: .complete)
                print("Broadcast \"\(broadcast.id)\" was completed")
            } catch {
                errorSubject.send("System detected error while finishing the video.\n\(error.localizedDescription)")
            }
            didFinishSubject.send()
        }
    }

    func didUserCancelPublishingVideo() {
        stopTasks()
        guard let broadcast = liveBroadcast else {
            didFinishSubject.send()
            return
        }
        Task {
            do {
                try await broadcastsAPI.deleteBroadcast(id: broadcast.id)
                print("Broadcast \"\(broadcast.id)\" was deleted!")
            } catch {
                errorSubject.send("System detected error while deleting the video.\n\(error.localizedDescription)\nTry to delete it in your YouTube account")
            }
            didFinishSubject.send()
        }
    }

    // MARK: - Monitoring and chat (YTLiveStreaming 1.1)

    private func stopTasks() {
        monitorTask?.cancel()
        chatTask?.cancel()
    }

    private func startMonitoring(broadcastID: String) {
        monitorTask?.cancel()
        monitorTask = Task { [weak self] in
            guard let api = self?.broadcastsAPI else { return }
            do {
                for try await event in api.monitor(broadcastID: broadcastID) {
                    guard let self else { return }
                    switch event {
                    case .snapshot(let snapshot):
                        stateSubject.send("status: \(snapshot.lifeCycleStatus.rawValue) [\(snapshot.streamStatus.rawValue);\(snapshot.streamHealth.rawValue)]")
                    case .encoderConnected:
                        stateSubject.send("encoder connected, going live…")
                    case .live:
                        stateSubject.send("● LIVE")
                        startChat()
                    case .transitionFailed(_, let error):
                        stateSubject.send(error.apiError?.reason ?? error.localizedDescription)
                    case .ended(let status):
                        stateSubject.send("ended (\(status.rawValue))")
                    case .transitionRequested, .testing, .pollFailed:
                        break
                    }
                }
            } catch is CancellationError {
                // finishPublishing / cancel
            } catch {
                self?.errorSubject.send(error.localizedDescription)
            }
        }
    }

    private func startChat() {
        guard chatTask == nil, let chatID = liveBroadcast?.snippet.liveChatId else { return }
        chatTask = Task { [weak self] in
            guard let api = self?.broadcastsAPI else { return }
            do {
                for try await batch in api.chatMessageStream(liveChatId: chatID) {
                    self?.chatSubject.send(batch)
                }
            } catch is CancellationError {
            } catch {
                self?.stateSubject.send("chat: \(error.localizedDescription)")
            }
        }
    }
}
