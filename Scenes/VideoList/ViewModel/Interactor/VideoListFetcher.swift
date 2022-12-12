//
//  VideoListFetcher.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import YTLiveStreaming
import Combine

struct SectionModel {
    var model: String
    var items: [LiveBroadcastStreamModel]
    var error: String?
}

extension SectionModel {
    init(original: SectionModel, items: [LiveBroadcastStreamModel]) {
        self = original
        self.items = items
    }
}

extension YTLiveVideoState: CustomStringConvertible {
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

    public var description: String {
        switch self {
        case .upcoming:
            return "Upcoming"
        case .active:
            return "Live now"
        case .completed:
            return "Completed"
        case .all:
            return "-"
        }
    }
}

class VideoSectionItems {
    lazy var data = {
        SectionModel(model: String(describing: section), items: [])
    }()
    private let section: YTLiveVideoState

    init(section: YTLiveVideoState) {
        self.section = section
    }
    
    func clear() {
        data.items.removeAll()
    }

    func loadData(with broadcastsAPI: BroadcastsAPI) async {
        let result = await withUnsafeContinuation { continuation in
            switch section {
            case .upcoming:
                broadcastsAPI.getUpcomingBroadcasts { result in
                    continuation.resume(returning: result)
                }
            case .active:
                broadcastsAPI.getLiveNowBroadcasts { result in
                    continuation.resume(returning: result)
                }
            case .completed:
                broadcastsAPI.getCompletedBroadcasts { result in
                    continuation.resume(returning: result)
                }
            default:
                continuation.resume(returning: .success([]))
            }
        }
        await self.parseResult(result)
    }

    private func parseResult(_ result: Result<[LiveBroadcastStreamModel], YTError>) async {
        let result: (String?, [LiveBroadcastStreamModel]) = await {
            switch result {
            case .success(let items):
                return (nil, items)
            case .failure(let error):
                if DSSettings.USE_MOCK_DATA {
                    switch await VideoListMockData.loadMockData(for: section) {
                    case .success(let items):
                        return (nil, items)
                    case .failure(let error):
                        return (error.message(), [])
                    }
                } else {
                    let errMessage = "\(section):\n" + error.message()
                    return (errMessage, [])
                }
            }
        }()
        (data.error, data.items) = result
    }
}

class VideoListFetcher: BroadcastsDataFetcher {
    var sectionModels = CurrentValueSubject<[SectionModel], Never>([])
    private var broadcastsAPI: BroadcastsAPI
    required init(broadcastsAPI: BroadcastsAPI) {
        self.broadcastsAPI = broadcastsAPI
    }
    private let sections = [
        VideoSectionItems(section: .upcoming),
        VideoSectionItems(section: .active),
        VideoSectionItems(section: .completed)
    ]

    func loadData() async {
        sections.forEach { $0.clear() }
        await withTaskGroup(of: Void.self) { group in
            sections.forEach { section in
                group.addTask {
                    await section.loadData(with: self.broadcastsAPI)
                }
            }
        }
        sectionModels.value = sections.map { $0.data }
    }
}
