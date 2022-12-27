//
//  BroadcastApiProtocol.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 27.10.2020.
//  Copyright © 2020 Serhii Krotkykh. All rights reserved.
//

import Foundation
import YTLiveStreaming

///
/// Facade for the YTLiveStreaming framework
///
protocol BroadcastsAPI {
    /**
        @param
        @return
     */
    func getUpcomingBroadcasts(_ completion: @escaping (Result<[LiveBroadcastStreamModel], YTError>) -> Void)
    /**
        @param
        @return
     */
    func getLiveNowBroadcasts(_ completion: @escaping (Result<[LiveBroadcastStreamModel], YTError>) -> Void)
    /**
        @param
        @return
     */
    func getCompletedBroadcasts(_ completion: @escaping (Result<[LiveBroadcastStreamModel], YTError>) -> Void)
    /**
        @param
        @return
     */
    func getAllBroadcasts(
        _ completion: @escaping ([LiveBroadcastStreamModel], [LiveBroadcastStreamModel], [LiveBroadcastStreamModel]) -> Void) throws
    /**
        @param
        @return
     */
    func getBroadcastListAsync() async throws -> [LiveBroadcastStreamModel]
    /**
     @param
     - title: The broadcast's title. Note that the broadcast represents exactly one YouTube video. You can set this field by modifying the broadcast resource or by setting the title field of the corresponding video resource.
      - description: The broadcast's description. As with the title, you can set this field by modifying the broadcast resource or by setting the description field of the corresponding video resource.
     - startTime: The date and time that the broadcast is scheduled to start. The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format. Creator Studio supports the ability to create a broadcast without scheduling a start time. In this case, the broadcast starts whenever the channel owner starts streaming. For these broadcasts, the datetime value corresponds to UNIX time zero, and this value cannot be changed via the API or in Creator Studio.
     - isReusable: Indicates whether the stream is reusable, which means that it can be bound to multiple broadcasts. It is common for broadcasters to reuse the same stream for many different broadcasts if those broadcasts occur at different times.
     - endDateTime:
     - selfDeclaredMadeForKids:
     - enableAutoStart:
     - enableAutoStop:
     - enableClosedCaptions:
     - enableDvr:
     - enableEmbed:
     - recordFromStart:
     - enableMonitorStream:
     - broadcastStreamDelayMs:
     @return
     */
    func createBroadcast(_ body: PostLiveBroadcastBody,
                         completion: @escaping (Result<LiveBroadcastStreamModel, YTError>) -> Void)
    /**
        @param
        @return
     */
    func updateBroadcast(_ broadcast: LiveBroadcastStreamModel, completion: @escaping (Bool) -> Void)
    /**
        @param
        @return
     */
    func startBroadcast(_ broadcast: LiveBroadcastStreamModel, delegate: LiveStreamTransitioning, completion: @escaping (String?, String?, Date?) -> Void)
    /**
        @param
        @return
     */
    func completeBroadcast(_ broadcast: LiveBroadcastStreamModel, completion: @escaping (Bool) -> Void)
    /**
     deleteAllBroadcastsAsync - async function deleting all broadcasts from the Ussr's account
     @param
     @return
        true if all broadcasts were deleted successfully. No error thrown.
     */
    func deleteAllBroadcastsAsync() async -> Bool
    /**
     deleteBroadcasts - async function deleting broadcasts by IDs
     @param
        broadcastsIDs - array of IDs which broadcasts will be deleted
     @return
        true if all broadcasts were deleted successfully
     */
    func deleteBroadcastsAsync(_ broadcastIDs: [String]) async -> Bool
    /**
        @param
        @return
     */
    func deleteBroadcast(id: String, completion: @escaping ((Result<Void, YTError>)) -> Void)
    /**
        @param
        @return
     */
    func transitionBroadcast(_ broadcast: LiveBroadcastStreamModel, toStatus: String, completion: @escaping (Bool) -> Void)
    /**
        @param
        @return
     */
    func getStatusBroadcast(_ broadcast: LiveBroadcastStreamModel, stream: LiveStreamModel, completion: @escaping (String?, String?, String?) -> Void)
    /**
        @param
        @return
     */
    func transitionBroadcastToLiveState(liveBroadcast: LiveBroadcastStreamModel, liveState: @escaping (Bool) -> Void)
    /**
        @param
        @return
     */
    func isYouTubeAvailable() -> Bool
}

extension YTLiveStreaming: BroadcastsAPI {
}
