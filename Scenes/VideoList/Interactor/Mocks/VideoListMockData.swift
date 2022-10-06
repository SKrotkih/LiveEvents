//
//  VideoListMockData.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 09.05.2021.
//  Copyright © 2021 Serhii Krotkykh. All rights reserved.
//
import Foundation
import YTLiveStreaming

// MARK: - Get mock data for the app UI testing

class VideoListMockData {
    static func loadMockData(for state: YTLiveVideoState) async -> Result<[LiveBroadcastStreamModel], LVError> {
        let data = await DecodeData.loadMockData("LiveBroadcast\(state.rawValue).json", as: LiveBroadcastListModel.self)
        switch data {
        case .success(let model):
            debugPrint(model)
            return .success(model.items)
        case .failure(let error):
            return .failure(LVError.message(error.message()))
        }
    }
}
