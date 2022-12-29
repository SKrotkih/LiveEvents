//
//  BroadcastListFetcher.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//
import Foundation
import YTLiveStreaming
import Combine

class BroadcastListFetcher: BroadcastsDataFetcher {
    var sectionModels = CurrentValueSubject<[SectionModel], YTError>([])
    private var broadcastsAPI: BroadcastsAPI
    
    required init(broadcastsAPI: BroadcastsAPI) {
        self.broadcastsAPI = broadcastsAPI
    }
    
    func fetchBroadcastListData(sections: YTLiveVideoState...) async {
        do {
            let broadcastList = try await broadcastsAPI.getBroadcastListAsync(.all)
            await parseResponse(.success(broadcastList), sections: sections)
        }
        catch {
            await parseResponse(.failure(error as! YTError), sections: sections)
        }
    }
    
    func deleteBroadcasts(_ broadcastIDs: [String]) async throws {
        try await self.broadcastsAPI.deleteBroadcastsAsync(broadcastIDs)
    }
}

// MARK: - Load Data: Private Methods

extension BroadcastListFetcher {
    private func parseResponse(_ result: Result<[LiveBroadcastStreamModel], YTError>, sections: [YTLiveVideoState]) async {
        switch result {
        case .success(let broadcastList):
            var _sectionModels = [SectionModel]()
            for section in sections {
                let sectionModel = await self.getSection(broadcastList: broadcastList, section: section)
                _sectionModels.append(sectionModel)
            }
            sectionModels.value = _sectionModels
        case .failure(let error):
            if DSSettings.USE_MOCK_DATA {
                var _sectionModels = [SectionModel]()
                for section in sections {
                    let res = await self.parseResult(for: section, .failure(error))
                    let sectionModel = SectionModel(section: section, items: res.1, error: res.0)
                    _sectionModels.append(sectionModel)
                }
                sectionModels.value = _sectionModels
            } else {
                sectionModels.send(completion: .failure(error))
            }
        }
    }

    private func getSection(broadcastList: [LiveBroadcastStreamModel],
                          section: YTLiveVideoState) async -> SectionModel {
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
