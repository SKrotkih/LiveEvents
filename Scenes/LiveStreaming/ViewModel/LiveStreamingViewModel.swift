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
    // Dependebcies
    @Lateinit var broadcastsAPI: BroadcastsAPI

    var rxDidUserFinishWatchVideo = PublishSubject<Bool>()
    var rxStateDescription = PublishSubject<String>()
    var rxError = PublishSubject<String>()

    fileprivate var liveBroadcast: LiveBroadcastStreamModel?

    fileprivate func didUserFinishWatchVideo() {
        rxDidUserFinishWatchVideo.onNext(true)
    }
}

// MARK: -

extension LiveStreamingViewModel {
    @MainActor private func startBroadcast(_ liveBroadcast: LiveBroadcastStreamModel) {
        self.liveBroadcast = liveBroadcast

        print("Watch the live video here: https://www.youtube.com/watch?v=\(liveBroadcast.id)")

        Router.openLiveVideoScreen()
    }
}

// MARK: - Live stream publishing output protocol

extension LiveStreamingViewModel: YouTubeLiveVideoPublisher {
    func willStartPublishing() async -> (String?, NSDate?) {
        guard let broadcast = self.liveBroadcast else {
            rxError.onNext("Need a broadcast object to start live video!")
            return (nil, nil)
        }
        guard let delegate = self as? LiveStreamTransitioning else {
            rxError.onNext("The Model does not conform LiveStreamTransitioning protocol")
            return (nil, nil)
        }
        do {
            let (streamName, streamUrl, scheduledStartTime) = try await broadcastsAPI.startBroadcastAsync(broadcast, delegate: delegate)
            if let streamName, let streamUrl, let scheduledStartTime {
                let streamUrl = "\(streamUrl)/\(streamName)"
                let startTime = scheduledStartTime as NSDate?
                return (streamUrl, startTime)
            } else {
                rxError.onNext("Start broadcast method returns wrong data")
                return (nil, nil)
            }
        } catch {
            rxError.onNext("\(error.localizedDescription). The Model does not conform LiveStreamTransitioning protocol")
            return (nil, nil)
        }
    }

    func finishPublishing() {
        guard let broadcast = self.liveBroadcast else {
            self.didUserFinishWatchVideo()
            return
        }
        Task {
            do {
                try await broadcastsAPI.completeBroadcastAsync(broadcast)
                print("Broadcast \"\(broadcast.id)\" was cancelled!")
            } catch {
                let message = (error as! YTError).message()
                self.rxError.onNext("System detected error while finishing the video./n\(message)")
            }
            didUserFinishWatchVideo()
        }
    }

    func didUserCancelPublishingVideo() {
        guard let broadcast = self.liveBroadcast else {
            self.didUserFinishWatchVideo()
            return
        }
        Task {
            do {
                try await broadcastsAPI.deleteBroadcast(id: broadcast.id)
                print("Broadcast \"\(broadcast.id)\" was deleted!")
            } catch {
                let message = (error as! YTError).message()
                self.rxError.onNext("System detected error while deleting the video./n\(message)/nTry to delete it in your YouTube account")
            }
            self.didUserFinishWatchVideo()
        }
    }
}

extension LiveStreamingViewModel {
    func didTransitionToLiveStatus() {
        rxStateDescription.onNext("● LIVE")
    }

    func didTransitionToStatus(broadcastStatus: String?, streamStatus: String?, healthStatus: String?) {
        if let broadcastStatus, let streamStatus, let healthStatus {
            let text = "status: \(broadcastStatus) [\(streamStatus);\(healthStatus)]"
            rxStateDescription.onNext(text)
        }
    }
}
