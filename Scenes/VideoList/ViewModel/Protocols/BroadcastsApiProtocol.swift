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
    func getBroadcastListAsync(_ status: YTLiveVideoState) async throws -> [LiveBroadcastStreamModel]
    /**
     @param
     @return
     */
    func createBroadcastAsync(_ body: PostLiveBroadcastBody) async throws -> LiveBroadcastStreamModel
    /**
     @param
     @return
     */
    func createBroadcast(_ body: PostLiveBroadcastBody,
                                liveStreamName: String,
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
    func deleteAllBroadcastsAsync() async throws -> Bool
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
