//
//  BroadcastListModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//
import Foundation
import YTLiveStreaming

struct SectionModel {
    var section: YTLiveVideoState
    var items: [String: [LiveBroadcastStreamModel]]
    var error: String?
}

extension SectionModel {
    init(original: SectionModel, items: [String: [LiveBroadcastStreamModel]]) {
        self = original
        self.items = items
    }
}

extension YTLiveVideoState {
    var index: Int {
        switch self {
        case .upcoming:
            return 0
        case .active:
            return 1
        case .completed:
            return 2
        case .all:
            return 3
        }
    }

    public var title: String {
        switch self {
        case .upcoming:
            return "Upcoming"
        case .active:
            return "Live now"
        case .completed:
            return "Completed"
        case .all:
            return "All"
        }
    }
}
