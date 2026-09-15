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
    var sectionModels = CurrentValueSubject<[SectionModel], YouTubeLiveError>([])
    private let broadcastsAPI: YouTubeLiveClient

    required init(broadcastsAPI: YouTubeLiveClient) {
        self.broadcastsAPI = broadcastsAPI
    }

    func fetchBroadcastListData(sections: BroadcastListFilter...) async {
        do {
            let broadcastList = try await broadcastsAPI.allBroadcasts(.all)
            await parseResponse(.success(broadcastList), sections: sections)
        } catch {
            await parseResponse(.failure(error.asYouTubeLiveError), sections: sections)
        }
    }

    func deleteBroadcasts(_ broadcastIDs: [String]) async throws {
        try await broadcastsAPI.deleteBroadcasts(ids: broadcastIDs)
    }
}

// MARK: - Load Data: Private Methods

extension BroadcastListFetcher {
    private func parseResponse(_ result: Result<[LiveBroadcastStreamModel], YouTubeLiveError>, sections: [BroadcastListFilter]) async {
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
                            section: BroadcastListFilter) async -> SectionModel {
        let items = broadcastList.filter { item in
            switch (item.lifeCycleStatus, section) {
            case (_, .all):
                return true
            case (.ready, .upcoming), (.created, .upcoming),
                 (.live, .active), (.liveStarting, .active), (.testing, .active), (.testStarting, .active),
                 (.complete, .completed):
                return true
            default:
                return false
            }
        }
        var groups: [String: [LiveBroadcastStreamModel]] = [:]
        items.forEach { item in
            groups[item.lifeCycleStatus.rawValue, default: []].append(item)
        }
        let res = await self.parseResult(for: section, .success(groups))
        return SectionModel(section: section, items: res.1, error: res.0)
    }

    private func parseResult(for section: BroadcastListFilter, _ result: Result<[String: [LiveBroadcastStreamModel]], YouTubeLiveError>) async -> (String?, [String: [LiveBroadcastStreamModel]]) {
        switch result {
        case .success(let items):
            if section == .all && items.isEmpty && DSSettings.USE_MOCK_DATA {
                return await getMockData(for: section)
            } else {
                return (nil, items)
            }
        case .failure(let error):
            if DSSettings.USE_MOCK_DATA {
                return await getMockData(for: section)
            } else {
                let errMessage = "\(section):\n" + error.localizedDescription
                return (errMessage, [:])
            }
        }
    }

    private func getMockData(for section: BroadcastListFilter) async -> (String?, [String: [LiveBroadcastStreamModel]]) {
        switch await VideoListMockData.loadMockData(for: section) {
        case .success(let items):
            return (nil, items)
        case .failure(let error):
            return (error.message(), [:])
        }
    }
}

extension Error {
    /// Anything the client throws is already a `YouTubeLiveError`; wrap the rest (e.g. `CancellationError`).
    var asYouTubeLiveError: YouTubeLiveError {
        (self as? YouTubeLiveError) ?? .transport(self)
    }
}
