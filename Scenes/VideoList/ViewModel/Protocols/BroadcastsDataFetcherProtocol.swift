//
//  BroadcastsDataFetcherProtocol.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 27.10.2020.
//  Copyright © 2020 Serhii Krotkykh. All rights reserved.
//

import Foundation
import YTLiveStreaming
import Combine

protocol BroadcastsDataFetcher: ObservableObject {
    /// send request to load source data for Broadcasts List
    ///
    /// - Parameters:
    ///
    /// - Returns:
    func loadData() async -> [SectionModel]
    /// Get Current Broadcast
    ///
    /// - Parameters:
    ///     - index of the Broadcast source data
    ///
    /// - Returns:
    func getCurrent(for index: Int) -> LiveBroadcastStreamModel
    /// Get Completed  Broadcast
    ///
    /// - Parameters:
    ///     - index of the Broadcast source data
    ///
    /// - Returns:
    func getPast(for index: Int) -> LiveBroadcastStreamModel
}
