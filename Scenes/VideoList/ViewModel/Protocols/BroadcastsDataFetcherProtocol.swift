//
//  BroadcastsDataFetcherProtocol.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 27.10.2020.
//

import Foundation
import YTLiveStreaming

protocol BroadcastsDataFetcher: Sendable {
    /// Downloads the channel's broadcasts and groups them into `sections`.
    /// A failed download is reported through `SectionModel.error` (mock data when `USE_MOCK_DATA`).
    func fetchBroadcastListData(sections: BroadcastListFilter...) async throws -> [SectionModel]
    /// Deletes broadcasts by id.
    func deleteBroadcasts(_ broadcastIDs: [String]) async throws
}
