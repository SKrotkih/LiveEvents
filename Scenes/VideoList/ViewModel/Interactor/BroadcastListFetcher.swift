import Foundation
import YTLiveStreaming

final class BroadcastListFetcher: BroadcastsDataFetcher {
    // Only immutable, Sendable state (the client is Sendable), so the fetcher is safely Sendable.
    private let broadcastsAPI: YouTubeLiveClient

    init(broadcastsAPI: YouTubeLiveClient) {
        self.broadcastsAPI = broadcastsAPI
    }

    func fetchBroadcastListData(sections: BroadcastListFilter...) async throws -> [SectionModel] {
        do {
            let broadcastList = try await broadcastsAPI.allBroadcasts(.all)
            var models: [SectionModel] = []
            for section in sections {
                models.append(await makeSection(broadcastList: broadcastList, section: section))
            }
            return models
        } catch {
            guard DSSettings.USE_MOCK_DATA else { throw error }
            var models: [SectionModel] = []
            for section in sections {
                let (message, items) = await mockData(for: section)
                models.append(SectionModel(section: section, items: items, error: message))
            }
            return models
        }
    }

    func deleteBroadcasts(_ broadcastIDs: [String]) async throws {
        // Purge: ends a running broadcast, removes the recording and the bound stream too.
        try await broadcastsAPI.purgeBroadcasts(ids: broadcastIDs)
    }

    // MARK: - Private

    private func makeSection(broadcastList: [LiveBroadcastStreamModel], section: BroadcastListFilter) async -> SectionModel {
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
        for item in items {
            groups[item.lifeCycleStatus.rawValue, default: []].append(item)
        }
        if section == .all && groups.isEmpty && DSSettings.USE_MOCK_DATA {
            let (message, mock) = await mockData(for: section)
            return SectionModel(section: section, items: mock, error: message)
        }
        return SectionModel(section: section, items: groups, error: nil)
    }

    private func mockData(for section: BroadcastListFilter) async -> (String?, [String: [LiveBroadcastStreamModel]]) {
        switch await VideoListMockData.loadMockData(for: section) {
        case .success(let items):
            return (nil, items)
        case .failure(let error):
            return (error.message(), [:])
        }
    }
}
