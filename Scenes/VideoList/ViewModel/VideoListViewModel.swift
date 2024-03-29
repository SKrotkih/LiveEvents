//
//  VideoListViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//
import UIKit
import YTLiveStreaming
import SwiftUI
import Combine

struct VideoListSection: Identifiable {
    var id: UUID
    var sectionName: String
    var rows: [VideoListRow]

    init(sectionName: String, rows: [VideoListRow]) {
        self.id = .init()
        self.sectionName = sectionName
        self.rows = rows
    }
}

struct VideoListRow: Identifiable {
    let model: LiveBroadcastStreamModel
    var id: UUID

    init(model: LiveBroadcastStreamModel) {
        self.model = model
        self.id = .init()
    }
}

enum ListByType {
    case byVideoState
    case byLifeCycleStatus
}

protocol VideoListViewModelObservable {
    var sections: [VideoListSection] { get set }
    var errorMessage: String { get set }
    var isDataDownloading: Bool { get set}
    var selectedListType: CurrentValueSubject<ListByType, Never> { get }
}

protocol VideoListViewModelLaunched {
    func didUserLogOutAction()
    func loadData(sortType: ListByType)
}

typealias VideoListViewModelInterface = ObservableObject & VideoListViewModelObservable & VideoListViewModelLaunched

final class VideoListViewModel: VideoListViewModelInterface {
    @Published var sections = [VideoListSection]()
    @Published var errorMessage = ""
    @Published var isDataDownloading = false

    var selectedListType = CurrentValueSubject<ListByType, Never>(.byLifeCycleStatus)
    let dataSource: any BroadcastsDataFetcher
    let store: AuthReduxStore

    private var disposableBag = Set<AnyCancellable>()

    init(store: AuthReduxStore, dataSource: any BroadcastsDataFetcher) {
        self.store = store
        self.dataSource = dataSource
        subscribeOnData()
        selectedListType
            .dropFirst(1)
            .sink { sortType in
                self.loadData(sortType: sortType)
            }
            .store(in: &disposableBag)
    }

    func loadData(sortType: ListByType) {
        Task {
            await MainActor.run { isDataDownloading = true }
            switch sortType {
            case .byLifeCycleStatus:
                await self.dataSource.fetchBroadcastListData(sections: .all)
            case .byVideoState:
                await self.dataSource.fetchBroadcastListData(sections: .upcoming, .active, .completed)
            }
            await MainActor.run { isDataDownloading.toggle() }
        }
    }

    func deleteBroadcasts(_ broadcastIDs: [String]) async throws {
        guard broadcastIDs.count > 0 else { return }
        await MainActor.run { isDataDownloading = true }
        do {
            try await dataSource.deleteBroadcasts(broadcastIDs)
            await MainActor.run { isDataDownloading.toggle() }
            loadData(sortType: selectedListType.value)
        } catch {
            await MainActor.run { isDataDownloading.toggle() }
            throw error
        }
    }

    // Subscribe on chenging list sort order
    private func subscribeOnData() {
        enum ConcurrencyWay {
            case asyncLet
            case taskGroup
        }
        // Strategy: which alhorothm will be used (just as an example)
        let concurrencyWay: ConcurrencyWay = .asyncLet

        dataSource.sectionModels
            .sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    Task {
                        await MainActor.run { self.errorMessage = error.message() }
                    }
                }},
                  receiveValue: { data in
                Task {
                    if concurrencyWay == .asyncLet {
                        // example of using async let
                        await self.getSectionedDataByAsyncLet(data)
                    } else {
                        // example of using task group
                        await self.getSectionedDataByTaskGroup(data)
                    }
                }
            })
            .store(in: &disposableBag)
    }

    private func getSectionedDataByAsyncLet(_ data: [SectionModel]) async {
        async let sectionedData = {
            switch self.selectedListType.value {
            case .byLifeCycleStatus:
                return await self.prepareAllSection(data: data)
            case .byVideoState:
                return await self.prepareSectioned(data: data, sections: .upcoming, .active, .completed)
            }}()
        async let parsedError = await self.parseError(data: data)
        let result = await (sectionedData, parsedError)
        await MainActor.run { self.sections = result.0 }
        await MainActor.run { self.errorMessage = result.1 }
    }

    private func getSectionedDataByTaskGroup(_ data: [SectionModel]) async {
        let _sections = await withTaskGroup(of: [VideoListSection].self,
                            returning: [VideoListSection].self,
                            body: { taskGroup in
            taskGroup.addTask {
                switch self.selectedListType.value {
                case .byLifeCycleStatus:
                    return await self.prepareAllSection(data: data)
                case .byVideoState:
                    return await self.prepareSectioned(data: data, sections: .upcoming, .active, .completed)
                }
            }
            var _sections = [VideoListSection]()
            for await result in taskGroup {
                _sections = result
            }
            return _sections
        })
        // Parse Error while loading data
        let error = Task { () -> String in
            return await self.parseError(data: data)
        }
        do {
            let result = await error.result
            let message = try result.get()
            await MainActor.run { self.errorMessage = message }
        } catch {
            await MainActor.run { self.errorMessage = "Unknown error" }
        }
        await MainActor.run { self.sections = _sections }
    }

    // Presenter: prepare reseived data for presenting
    // [SectionModel] - model
    // [VideoListSection] - presentable data
    private func prepareSectioned(data: [SectionModel], sections: YTLiveVideoState...) async -> [VideoListSection] {
        var result = [VideoListSection]()
        data.forEach { sectionModel in
            if sections.first(where: { sectionModel.section == $0 }) != nil {
                var rows = [VideoListRow]()
                sectionModel.items.forEach {
                    let items = $0.value
                    items.forEach { streamModel in
                        rows.append(
                            VideoListRow(model: streamModel)
                        )
                    }
                }
                result.append(VideoListSection(sectionName: sectionModel.section.title,
                                               rows: rows))
            }
        }
        return result
    }

    private func prepareAllSection(data: [SectionModel]) async -> [VideoListSection] {
        var result = [VideoListSection]()
        data.forEach { sectionModel in
            sectionModel.items.keys.forEach { sectionName in
                var rows = [VideoListRow]()
                sectionModel.items[sectionName]?.forEach { streamModel in
                    rows.append(
                        VideoListRow(model: streamModel)
                    )
                }
                result.append(VideoListSection(sectionName: sectionName,
                                               rows: rows))
            }
        }
        return result
    }

    private func parseError(data: [SectionModel]) async -> String {
        let message: String = data.reduce("") { partialResult, item in
            var message = ""
            if let errorMessage = item.error {
                message += errorMessage + "\n"
            }
            return partialResult + message
        }
        return message
    }

    func didUserLogOutAction() {
        store.stateDispatch(action: .logOut)
    }
}
