//
//  LiveStreamingViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import YTLiveStreaming
import RxSwift

class LiveStreamingViewModel: NSObject {
    // Dependencies
    @Lateinit var broadcastsAPI: YouTubeLiveClient

    var rxDidUserFinishWatchVideo = PublishSubject<Bool>()
    var rxStateDescription = PublishSubject<String>()
    var rxError = PublishSubject<String>()

    fileprivate var liveBroadcast: LiveBroadcastStreamModel?
    /// Polls YouTube and takes the broadcast live once the encoder is sending (YTLiveStreaming 1.0).
    private var monitorTask: Task<Void, Never>?

    fileprivate func didUserFinishWatchVideo() {
        rxDidUserFinishWatchVideo.onNext(true)
    }

    deinit {
        monitorTask?.cancel()
    }
}

// MARK: -

extension LiveStreamingViewModel {
    @MainActor private func startBroadcast(_ liveBroadcast: LiveBroadcastStreamModel) {
        self.liveBroadcast = liveBroadcast

        print("Watch the live video here: \(liveBroadcast.watchURL?.absoluteString ?? liveBroadcast.id)")

        Router.openLiveVideoScreen()
    }
}

// MARK: - Live stream publishing output protocol

extension LiveStreamingViewModel: YouTubeLiveVideoPublisher {
    /// Returns the RTMP URL (address + stream key) for LFLiveKit and starts monitoring the broadcast.
    func willStartPublishing() async -> (String?, NSDate?) {
        guard let broadcast = self.liveBroadcast else {
            rxError.onNext("Need a broadcast object to start live video!")
            return (nil, nil)
        }
        guard let streamID = broadcast.contentDetails?.boundStreamId, !streamID.isEmpty else {
            rxError.onNext("The broadcast has no bound stream. Create it with a stream first.")
            return (nil, nil)
        }
        do {
            let stream = try await broadcastsAPI.stream(id: streamID)
            guard let ingestion = stream.cdn?.ingestionInfo else {
                rxError.onNext("YouTube returned a stream without ingestion info")
                return (nil, nil)
            }
            startMonitoring(broadcastID: broadcast.id)
            let startTime = (broadcast.snippet.scheduledStartTime ?? Date()) as NSDate
            return (ingestion.fullIngestionURL, startTime)
        } catch {
            rxError.onNext(error.localizedDescription)
            return (nil, nil)
        }
    }

    func finishPublishing() {
        monitorTask?.cancel()
        guard let broadcast = self.liveBroadcast else {
            self.didUserFinishWatchVideo()
            return
        }
        Task {
            do {
                try await broadcastsAPI.transition(broadcastID: broadcast.id, to: .complete)
                print("Broadcast \"\(broadcast.id)\" was completed")
            } catch {
                self.rxError.onNext("System detected error while finishing the video.\n\(error.localizedDescription)")
            }
            didUserFinishWatchVideo()
        }
    }

    func didUserCancelPublishingVideo() {
        monitorTask?.cancel()
        guard let broadcast = self.liveBroadcast else {
            self.didUserFinishWatchVideo()
            return
        }
        Task {
            do {
                try await broadcastsAPI.deleteBroadcast(id: broadcast.id)
                print("Broadcast \"\(broadcast.id)\" was deleted!")
            } catch {
                self.rxError.onNext("System detected error while deleting the video.\n\(error.localizedDescription)\nTry to delete it in your YouTube account")
            }
            self.didUserFinishWatchVideo()
        }
    }
}

// MARK: - Status monitoring (replaces the 0.2.x LiveStreamTransitioning delegate)

extension LiveStreamingViewModel {
    private func startMonitoring(broadcastID: String) {
        monitorTask?.cancel()
        monitorTask = Task { [weak self] in
            guard let api = self?.broadcastsAPI else { return }
            do {
                for try await event in api.monitor(broadcastID: broadcastID) {
                    guard let self else { return }
                    switch event {
                    case .snapshot(let snapshot):
                        self.rxStateDescription.onNext(
                            "status: \(snapshot.lifeCycleStatus.rawValue) [\(snapshot.streamStatus.rawValue);\(snapshot.streamHealth.rawValue)]"
                        )
                    case .encoderConnected:
                        self.rxStateDescription.onNext("encoder connected, going live…")
                    case .live:
                        self.rxStateDescription.onNext("● LIVE")
                    case .transitionFailed(_, let error):
                        self.rxStateDescription.onNext(error.apiError?.reason ?? error.localizedDescription)
                    case .ended(let status):
                        self.rxStateDescription.onNext("ended (\(status.rawValue))")
                    case .transitionRequested, .testing, .pollFailed:
                        break
                    }
                }
            } catch is CancellationError {
                // finishPublishing / cancel
            } catch {
                self?.rxError.onNext(error.localizedDescription)
            }
        }
    }
}
