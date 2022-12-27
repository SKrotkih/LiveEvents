//
//  BroadcastListFetcher.swift
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

class BroadcastListFetcher: BroadcastsDataFetcher {
    var sectionModels = CurrentValueSubject<[SectionModel], Never>([])
    private var broadcastsAPI: BroadcastsAPI

    required init(broadcastsAPI: BroadcastsAPI) {
        self.broadcastsAPI = broadcastsAPI
    }

    func fetchData(sections: YTLiveVideoState...) async {
        let _sectionModels = await withTaskGroup(of: [SectionModel].self,
                                                 returning: [SectionModel].self,
                                                 body: { taskGroup in
            sections.forEach { section in
                taskGroup.addTask {
                    let sectionData = await self.loadData(for: section, with: self.broadcastsAPI)
                    return [sectionData]
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
    
    private func loadData(for section: YTLiveVideoState, with broadcastsAPI: BroadcastsAPI) async -> SectionModel {
        do {
            let broadcastList = try await broadcastsAPI.getBroadcastListAsync()
            let items = broadcastList.compactMap { listItem in
                let lifeCycleStatus = listItem.status?.lifeCycleStatus ?? "complete"
                switch lifeCycleStatus {
                case "ready" where (section == .upcoming):
                    return listItem
                case "live" where (section == .active):
                    return listItem
                case "complete" where (section == .completed):
                    return listItem
                default:
                    return nil
                }
            }
            var a: [String: [LiveBroadcastStreamModel]] = [:]
            items.forEach { item in
                if let status = item.status?.lifeCycleStatus.lowercased() {
                    if a[status] == nil {
                        a[status] = []
                    }
                    a[status]?.append(item)
                }
            }
            let res = await self.parseResult(for: section, .success(a))
            return SectionModel(section: section, items: res.1, error: res.0)
        } catch {
            let res = await self.parseResult(for: section, .failure(error as! YTError))
            return SectionModel(section: section, items: res.1, error: res.0)
        }
    }

    private func parseResult(for section: YTLiveVideoState, _ result: Result<[String: [LiveBroadcastStreamModel]], YTError>) async -> (String?, [String: [LiveBroadcastStreamModel]]) {
        let result: (String?, [String: [LiveBroadcastStreamModel]]) = await {
            switch result {
            case .success(let items):
                if section == .all && items.count == 0 && DSSettings.USE_MOCK_DATA {
                    return await getMockData(for: section)
                } else {
                    return (nil, items)
                }
            case .failure(let error):
                if DSSettings.USE_MOCK_DATA {
                    return await getMockData(for: section)
                } else {
                    let errMessage = "\(section):\n" + error.message()
                    return (errMessage, [:])
                }
            }
        }()
        return result
    }
    
    private func getMockData(for section: YTLiveVideoState) async -> (String?, [String: [LiveBroadcastStreamModel]]) {
        switch await VideoListMockData.loadMockData(for: section) {
        case .success(let items):
            return (nil, items)
        case .failure(let error):
            return (error.message(), [:])
        }
    }
}

// MARK: - Delete Broadcasts Request

extension BroadcastListFetcher {
    func deleteBroadcasts(_ broadcastIDs: [String]) async -> Bool {
        return await self.broadcastsAPI.deleteBroadcastsAsync(broadcastIDs)
    }
}
