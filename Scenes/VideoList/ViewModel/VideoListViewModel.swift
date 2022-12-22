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

struct VideoListSection: Codable, Identifiable, Hashable {
    var id: UUID
    var sectionName: String
    var rows: [VideoListRow]

    init(sectionName: String, rows: [VideoListRow]) {
        self.id = .init()
        self.sectionName = sectionName
        self.rows = rows
    }
}

struct VideoListRow: Codable, Identifiable, Hashable {
    let id: UUID
    let videoId: String
    let status: String
    let title: String
    let description: String
    let publishedAt: String

    init(videoId: String, status: String, title: String, description: String, publishedAt: String) {
        self.id = .init()
        self.videoId = videoId
        self.title = title
        self.description = description
        self.status = status
        self.publishedAt = publishedAt
    }
}

protocol VideoListViewModelObservable {
    var sections: [VideoListSection] { get set }
    var errorMessage: String { get set }
    var isDataDownloading: Bool { get set}
}

protocol VideoListViewModelLaunched {
    func didUserLogOutAction()
    func loadData()
}

typealias VideoListViewModelInterface = ObservableObject & VideoListViewModelObservable & VideoListViewModelLaunched

final class VideoListViewModel: VideoListViewModelInterface {
    @Published var sections = [VideoListSection]()
    @Published var errorMessage = ""
    @Published var isDataDownloading = false

    private var disposableBag = Set<AnyCancellable>()
    
    let dataSource: any BroadcastsDataFetcher
    let store: AuthReduxStore

    init(store: AuthReduxStore, dataSource: any BroadcastsDataFetcher) {
        self.store = store
        self.dataSource = dataSource
        subscribeOnData()
    }

    func loadData() {
        Task {
            await MainActor.run { isDataDownloading = true }
            await dataSource.fetchData()
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
                        async let formattedData = await self.format(data: data)
                        async let parsedError = await self.parseError(data: data)
                        let result = await (formattedData, parsedError)
                        await MainActor.run { self.sections = result.0 }
                        await MainActor.run { self.errorMessage = result.1 }
                    } else {
                        // example of using task group
                        let _sections = await withTaskGroup(of: [VideoListSection].self,
                                            returning: [VideoListSection].self,
                                            body: { taskGroup in
                            taskGroup.addTask {
                                return await self.format(data: data)
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
    private func format(data: [SectionModel]) async -> [VideoListSection] {
        return data.map({ sectionModel in
            var rows = [VideoListRow]()
            sectionModel.items.forEach {
                let status = $0.key
                let items = $0.value
                items.forEach { streamModel in
                    rows.append(
                        VideoListRow(videoId: streamModel.id,
                                     status: status,
                                     title: streamModel.snippet.title,
                                     description: streamModel.snippet.description,
                                     publishedAt: dateFormatted(streamModel.snippet.publishedAt))
                    )
                }
            }
            return VideoListSection(sectionName: sectionModel.model,
                                    rows: rows)
        })
    }

    private func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, d MMM y"
        return formatter.string(from: date)
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
