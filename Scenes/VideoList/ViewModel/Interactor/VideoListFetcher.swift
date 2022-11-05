//
//  VideoListFetcher.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import YTLiveStreaming

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
    func description() -> String {
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

class VideoListFetcher: BroadcastsDataFetcher {
    private var broadcastsAPI: BroadcastsAPI
    required init(broadcastsAPI: BroadcastsAPI) {
        self.broadcastsAPI = broadcastsAPI
    }
    private var data = [
        SectionModel(model: YTLiveVideoState.upcoming.description(), items: []),
        SectionModel(model: YTLiveVideoState.active.description(), items: []),
        SectionModel(model: YTLiveVideoState.completed.description(), items: [])
    ]

    func getUpcoming(for index: Int) -> LiveBroadcastStreamModel {
        return getData(index: index, for: .upcoming)
    }

    func getCurrent(for index: Int) -> LiveBroadcastStreamModel {
        return getData(index: index, for: .active)
    }

    func getPast(for index: Int) -> LiveBroadcastStreamModel {
        return getData(index: index, for: .completed)
    }

    private func getData(index: Int, for state: YTLiveVideoState) -> LiveBroadcastStreamModel {
        let items = data[state.index].items
        assert(index < items.count, "Video list index (\(index) from \(items.count)) is wrong")
        return items[index]
    }

    func loadData() async -> [SectionModel] {
        for i in 0..<data.count {
            data[i].items.removeAll()
        }
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.getUpcomingBroadcasts()
            }
            group.addTask {
                await self.getLiveNowBroadcasts()
            }
            group.addTask {
                await self.getCompletedBroadcasts()
            }
        }
        return self.data
    }

    private func getUpcomingBroadcasts() async {
        let result = await withUnsafeContinuation { continuation in
            self.broadcastsAPI.getUpcomingBroadcasts { result in
                continuation.resume(returning: result)
            }
        }
        await self.parseResult(result, for: .upcoming)
    }

    private func getLiveNowBroadcasts() async {
        let result = await withUnsafeContinuation { continuation in
            self.broadcastsAPI.getLiveNowBroadcasts { result in
                continuation.resume(returning: result)
            }
        }
        await self.parseResult(result, for: .active)
    }

    private func getCompletedBroadcasts() async {
        let result = await withUnsafeContinuation { continuation in
            self.broadcastsAPI.getCompletedBroadcasts { result in
                continuation.resume(returning: result)
            }
        }
        await self.parseResult(result, for: .completed)
    }

    private func parseResult(_ result: Result<[LiveBroadcastStreamModel], YTError>, for state: YTLiveVideoState) async {
        switch result {
        case .success(let items):
            data[state.index].items += items
        case .failure(let error):
            if DSSettings.USE_MOCK_DATA {
                switch await VideoListMockData.loadMockData(for: state) {
                case .success(let items):
                    data[state.index].error = nil
                    data[state.index].items = items
                case .failure(let error):
                    data[state.index].error = error.message()
                    data[state.index].items = []
                }
            } else {
                let errMessage = state.description() + ":\n" + error.message()
                data[state.index].error = errMessage
                data[state.index].items = []
            }
        }
    }
}
