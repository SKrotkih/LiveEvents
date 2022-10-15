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

protocol VideoListViewModelObservable: ObservableObject {
    var sections: [VideoListSection] { get set }
    var errorMessage: String { get set }
    var isDataDownloading: Bool { get set}
}

protocol VideoListViewModelLaunched {
    func didCloseViewAction()
    func didUserLogOutAction()
    func createBroadcast()
    func loadData()
}

typealias VideoListViewModelInterface = VideoListViewModelObservable & VideoListViewModelLaunched

final class VideoListViewModel: VideoListViewModelInterface {
    @Published var sections = [VideoListSection]()
    @Published var errorMessage = ""
    @Published var isDataDownloading = false

    // Default value of the used video player
    private static let playerType: VideoPlayerType = .DefaultVideoPlayer

    @Lateinit var dataSource: any BroadcastsDataFetcher
    @Lateinit var store: AuthReduxStore

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
        isDataDownloading = true
        Task {
            let data = await dataSource.loadData()
            await parseResult(data: data)
            await parseError(data: data)
            await MainActor.run { isDataDownloading.toggle() }
        }
    }

    // Presenter
    @MainActor
    private func parseResult(data: [SectionModel]) async {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, d MMM y"
        sections = data.map({ sectionModel in
            VideoListSection(sectionName: sectionModel.model,
                             rows: sectionModel.items.map({ streamModel in
                VideoListRow(videoId: streamModel.id,
                             title: streamModel.snippet.title,
                             publishedAt: formatter.string(from: streamModel.snippet.publishedAt))
            }))
        })
    }

    @MainActor
    private func parseError(data: [SectionModel]) async {
        let message: String = data.reduce("") { partialResult, item in
            var message = ""
            if let errorMessage = item.error {
                message += errorMessage + "\n"
            }
            return partialResult + message
        }
        if !message.isEmpty {
            errorMessage = message
        }
    }

    func didUserLogOutAction() {
        store.stateDispatch(action: .logOut)
    }

    @MainActor
    func didCloseViewAction() {
        Router.openMainScreen()
    }

    @MainActor func createBroadcast() {
        Router.showNewStreamScreen()
    }
}
