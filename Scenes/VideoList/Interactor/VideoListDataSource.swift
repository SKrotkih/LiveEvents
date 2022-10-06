//
//  VideoListDataSource.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import YTLiveStreaming
import RxDataSources
import RxSwift

enum DSSettings {
    static let USE_MOCK_DATA = true
}

struct SectionModel {
    var model: String
    var items: [LiveBroadcastStreamModel]
    var error: String?
}

extension SectionModel: SectionModelType {
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

class VideoListDataSource: NSObject, BroadcastsDataFetcher {
    var broadcastsAPI: BroadcastsAPI!

    let dispatchGroup = DispatchGroup()

    var rxData = PublishSubject<[SectionModel]>()

    private var data = [
        SectionModel(model: YTLiveVideoState.upcoming.description(), items: []),
        SectionModel(model: YTLiveVideoState.active.description(), items: []),
        SectionModel(model: YTLiveVideoState.completed.description(), items: [])
    ]

    func getUpcoming(for index: Int) -> LiveBroadcastStreamModel {
        assert(index < data[YTLiveVideoState.upcoming.index].items.count, "Upcoming list index is wrong")
        return self.data[YTLiveVideoState.upcoming.index].items[index]
    }

    func getCurrent(for index: Int) -> LiveBroadcastStreamModel {
        assert(index < data[YTLiveVideoState.active.index].items.count, "Current  list index is wrong")
        return self.data[YTLiveVideoState.active.index].items[index]
    }

    func getPast(for index: Int) -> LiveBroadcastStreamModel {
        assert(index < data[YTLiveVideoState.completed.index].items.count, "Past video list index is wrong")
        return self.data[YTLiveVideoState.completed.index].items[index]
    }

    func loadData() async {
        for i in 0..<data.count {
            data[i].items.removeAll()
        }
        await updateUI()
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
        await updateUI()
    }

    @MainActor
    private func updateUI() {
        self.rxData.onNext(self.data)
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
