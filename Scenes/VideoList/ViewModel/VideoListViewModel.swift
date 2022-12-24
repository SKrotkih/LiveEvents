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
                await self.dataSource.fetchData(sections: .all)
            case .byVideoState:
                await self.dataSource.fetchData(sections: .upcoming, .active, .completed)
            }
            await MainActor.run { isDataDownloading.toggle() }
        }
    }

    private func subscribeOnData() {
        enum ConcurrencyWay {
            case asyncLet
            case taskGroup
        }
        let concurrencyWay: ConcurrencyWay = .asyncLet
        
        dataSource.sectionModels
            .sink(receiveValue: { data in
                Task {
                    if concurrencyWay == .asyncLet {
                        // example of using async let
                        async let sectionedData = self.selectedListType.value == .byLifeCycleStatus ?
                            await self.prepareAllSection(data: data) :
                            await self.prepareSectioned(data: data, sections: .upcoming, .active, .completed)
                        async let parsedError = await self.parseError(data: data)
                        let result = await (sectionedData, parsedError)
                        await MainActor.run { self.sections = result.0 }
                        await MainActor.run { self.errorMessage = result.1 }
                    } else {
                        // example of using task group
                        let _sections = await withTaskGroup(of: [VideoListSection].self,
                                            returning: [VideoListSection].self,
                                            body: { taskGroup in
                            taskGroup.addTask {
                                if self.selectedListType.value == .byLifeCycleStatus {
                                    return await self.prepareAllSection(data: data)
                                } else {
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
                }
            })
            .store(in: &disposableBag)
    }

    // Presenter: prepare data for presenting
    // [SectionModel] - model
    // [VideoListSection] - presentable data
    private func prepareSectioned(data: [SectionModel], sections: YTLiveVideoState...) async -> [VideoListSection] {
        var result = [VideoListSection]()
        data.forEach { sectionModel in
            if sections.first(where: { sectionModel.section == $0 }) != nil {
                var rows = [VideoListRow]()
                sectionModel.items.forEach {
                    let status = $0.key
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
