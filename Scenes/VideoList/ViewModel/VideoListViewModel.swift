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

enum VideoPlayerType {
    case DefaultVideoPlayer
    case oldVersionForIos8
    case AVPlayerViewController
}

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
    var id: UUID
    var videoId: String
    var title: String
    var publishedAt: String

    init(videoId: String, title: String, publishedAt: String) {
        self.id = .init()
        self.videoId = videoId
        self.title = title
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

    // Default value of the used video player
    private static let playerType: VideoPlayerType = .DefaultVideoPlayer

    let dataSource: any BroadcastsDataFetcher
    let store: AuthReduxStore

    init(store: AuthReduxStore, dataSource: any BroadcastsDataFetcher) {
        self.store = store
        self.dataSource = dataSource
    }

    lazy private var videoPlayer = YouTubePlayer()

    var playerFactory: YouTubeVideoPlayed {
        switch VideoListViewModel.playerType {
        case .oldVersionForIos8:
            return XCDYouTubeVideoPlayer8()
        case .AVPlayerViewController:
            return XCDYouTubeVideoPlayer()
        case .DefaultVideoPlayer:
            return YTVideoPlayer()
        }
    }

    func loadData() {
        Task {
            await MainActor.run { isDataDownloading = true }
            let data = await dataSource.loadData()
            // example of using task group
            let _sections = await withTaskGroup(of: [VideoListSection].self,
                                returning: [VideoListSection].self,
                                body: { taskGroup in
                taskGroup.addTask {
                    return await self.parseResult(data: data)
                }
                var _sections = [VideoListSection]()
                for await result in taskGroup {
                    _sections = result
                }
                return _sections
            })
            // example of parsing task return result
            let error = Task { () -> String in
                return await self.parseError(data: data)
            }
            do {
                let result = await error.result
                let message = try result.get()
                if !message.isEmpty {
                    await MainActor.run { self.errorMessage = message }
                }
            } catch {
                print("Unknown error.")
            }
            await MainActor.run { sections = _sections }
            await MainActor.run { isDataDownloading.toggle() }
        }
    }

    // Presenter
    private func parseResult(data: [SectionModel]) async -> [VideoListSection] {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, d MMM y"
        return data.map({ sectionModel in
            VideoListSection(sectionName: sectionModel.model,
                             rows: sectionModel.items.map({ streamModel in
                VideoListRow(videoId: streamModel.id,
                             title: streamModel.snippet.title,
                             publishedAt: formatter.string(from: streamModel.snippet.publishedAt))
            }))
        })
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
