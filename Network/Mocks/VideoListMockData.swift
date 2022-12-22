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
    static func loadMockData(for state: YTLiveVideoState) async -> Result<[String: [LiveBroadcastStreamModel]], LVError> {
        let fileName = {
            switch state {
            case .completed:
                return "LiveBroadcastcompleted"
            case .active:
                return "LiveBroadcastactive"
            case .upcoming:
                return "LiveBroadcastupcoming"
            case .all:
                return "LiveBroadcastAll"
            }
        }()
        let data = await DecodeData.loadMockData("\(fileName).json", as: LiveBroadcastListModel.self)
        var a: [String: [LiveBroadcastStreamModel]] = [:]
        for status in LifiCycleStatus.allCases {
            a[status.rawValue] = []
        }
        switch data {
        case .success(let model):
            model.items.forEach { item in
                if let status = item.status?.lifeCycleStatus {
                    a[status]?.append(item)
                }
            }
            debugPrint(a)
            return .success(a)
        case .failure(let error):
            return .failure(LVError.message(error.message()))
        }
    }
}
