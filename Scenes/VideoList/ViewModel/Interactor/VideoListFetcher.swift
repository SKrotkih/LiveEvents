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

class VideoSectionItems {
    lazy var data = {
        SectionModel(section: section, items: [:])
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
            case .all:
                broadcastsAPI.getAllBroadcasts { (result1, result2, result3) in
                    var data = [LiveBroadcastStreamModel]()
                    if let result1 { data.append(contentsOf: result1) }
                    if let result2 { data.append(contentsOf: result2) }
                    if let result3 { data.append(contentsOf: result3) }
                    continuation.resume(returning: .success(data))
                }
            }
        }
        switch result {
        case .success(let items):
            var a: [String: [LiveBroadcastStreamModel]] = [:]
            items.forEach { item in
                if let status = item.status?.lifeCycleStatus.lowercased() {
                    if a[status] == nil {
                        a[status] = []
                    }
                    a[status]?.append(item)
                }
            }
            await self.parseResult(.success(a))
        case .failure(let error):
            await self.parseResult(.failure(error))
        }
    }

    private func parseResult(_ result: Result<[String: [LiveBroadcastStreamModel]], YTError>) async {
        let result: (String?, [String: [LiveBroadcastStreamModel]]) = await {
            switch result {
            case .success(let items):
                if section == .all && items.count == 0 && DSSettings.USE_MOCK_DATA {
                    return await getMockData()
                } else {
                    return (nil, items)
                }
            case .failure(let error):
                if DSSettings.USE_MOCK_DATA {
                    return await getMockData()
                } else {
                    let errMessage = "\(section):\n" + error.message()
                    return (errMessage, [:])
                }
            }
        }()
        (data.error, data.items) = result
    }
    
    private func getMockData() async -> (String?, [String: [LiveBroadcastStreamModel]]) {
        switch await VideoListMockData.loadMockData(for: section) {
        case .success(let items):
            return (nil, items)
        case .failure(let error):
            return (error.message(), [:])
        }
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
        VideoSectionItems(section: .completed),
        VideoSectionItems(section: .all)
    ]

    func fetchData(sections: YTLiveVideoState...) async {
        let _sectionModels = await withTaskGroup(of: [SectionModel].self,
                                                 returning: [SectionModel].self,
                                                 body: { taskGroup in
            sections.forEach { section in
                taskGroup.addTask {
                    let sectionItems = VideoSectionItems(section: section)
                    await sectionItems.loadData(with: self.broadcastsAPI)
                    return [sectionItems.data]
                }
            }
            var _sectionModels = [SectionModel]()
            for await result in taskGroup {
                _sectionModels.append(contentsOf: result)
            }
            return _sectionModels
        })
        sectionModels.value = _sectionModels
    }
}
