//
//  VideoListViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//
import Foundation
import YTLiveStreaming

struct VideoListSection: Identifiable {
    let id = UUID()
    let sectionName: String
    let rows: [VideoListRow]
}

struct VideoListRow: Identifiable {
    let model: LiveBroadcastStreamModel
    var id: String { model.id }
}

enum ListByType {
    case byVideoState
    case byLifeCycleStatus
}

@MainActor
final class VideoListViewModel: ObservableObject {
    @Published private(set) var sections = [VideoListSection]()
    @Published var errorMessage = ""
    @Published private(set) var isDataDownloading = false
    @Published private(set) var listType: ListByType = .byLifeCycleStatus

    private let dataSource: any BroadcastsDataFetcher
    private let store: AuthReduxStore

    init(store: AuthReduxStore, dataSource: any BroadcastsDataFetcher) {
        self.store = store
        self.dataSource = dataSource
    }

    func select(listType: ListByType) {
        guard listType != self.listType else { return }
        self.listType = listType
        Task { await loadData() }
    }

    func loadData() async {
        isDataDownloading = true
        defer { isDataDownloading = false }
        do {
            let data: [SectionModel]
            switch listType {
            case .byLifeCycleStatus:
                data = try await dataSource.fetchBroadcastListData(sections: .all)
                sections = Self.sectionsByLifeCycle(data)
            case .byVideoState:
                data = try await dataSource.fetchBroadcastListData(sections: .upcoming, .active, .completed)
                sections = Self.sectionsByState(data)
            }
            errorMessage = data.compactMap(\.error).joined(separator: "\n")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteBroadcasts(_ broadcastIDs: [String]) async throws {
        guard !broadcastIDs.isEmpty else { return }
        isDataDownloading = true
        do {
            try await dataSource.deleteBroadcasts(broadcastIDs)
        } catch {
            isDataDownloading = false
            throw error
        }
        isDataDownloading = false
        await loadData()
    }

    func logOut() {
        store.dispatch(.logOut)
    }

    // MARK: - Presenter

    /// One section per life-cycle status (`ready`, `live`, `complete`, …).
    private static func sectionsByLifeCycle(_ data: [SectionModel]) -> [VideoListSection] {
        data.flatMap { model in
            model.items.keys.sorted().map { status in
                VideoListSection(sectionName: status,
                                 rows: (model.items[status] ?? []).map(VideoListRow.init))
            }
        }
    }

    /// Upcoming / Live now / Completed.
    private static func sectionsByState(_ data: [SectionModel]) -> [VideoListSection] {
        data.map { model in
            VideoListSection(sectionName: model.section.title,
                             rows: model.items.values.flatMap { $0 }.map(VideoListRow.init))
        }
    }
}
