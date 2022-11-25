//
//  VideoListMockData.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 09.05.2021.
//
import Foundation
import YTLiveStreaming

///
/// Get test mock data
///
struct VideoListMockData {
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
