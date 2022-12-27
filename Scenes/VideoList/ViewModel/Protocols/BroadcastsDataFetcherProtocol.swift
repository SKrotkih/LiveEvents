//
//  BroadcastsDataFetcherProtocol.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 27.10.2020.
//

import Foundation
import YTLiveStreaming
import Combine

protocol BroadcastsDataFetcher: ObservableObject {
    /// Dowload source data for Broadcast List
    ///
    /// - Parameters:
    ///
    /// - Returns:
    func fetchData(sections: YTLiveVideoState...) async
    /// Get Current Broadcast
    ///
    /// - Parameters:
    ///     - index of the Broadcast source data
    ///
    /// - Returns:
    var sectionModels: CurrentValueSubject<[SectionModel], Never> { get }
    /// Delete Broadcasts
    ///
    /// - Parameters:
    ///     - array of broadcasts id
    ///
    /// - Returns:
    func deleteBroadcasts(_ broadcastIDs: [String]) async -> Bool
}
