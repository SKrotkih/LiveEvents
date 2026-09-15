//
//  YouTubeLiveVideoPublisher.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 27.10.2020.
//

import Foundation
import Combine
import YTLiveStreaming

protocol YouTubeLiveVideoPublisher: AnyObject {
    /// Returns the RTMP URL (address + stream key) and the scheduled start, and starts monitoring.
    func willStartPublishing() async -> (String?, Date?)
    func finishPublishing()
    func didUserCancelPublishingVideo()

    var didFinish: AnyPublisher<Void, Never> { get }
    var stateDescription: AnyPublisher<String, Never> { get }
    var errorMessage: AnyPublisher<String, Never> { get }
    /// Batches of live-chat messages, in arrival order.
    var chatMessages: AnyPublisher<[LiveChatMessage], Never> { get }
}
