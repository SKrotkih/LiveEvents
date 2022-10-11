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
    case oldVersionForIos8
    case AVPlayerViewController
    case VideoPlayerViewController
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
    var title: String
    var publishedAt: String

    init(title: String, publishedAt: String) {
        self.id = .init()
        self.title = title
        self.publishedAt = publishedAt
    }
}

class VideoListViewModel: VideoListViewModelInterface {
    @Published var sections = [VideoListSection]()
    @Published var errorMessage = ""
    @Published var isDataDownloading = false

    // Default value of the used video player
    private static let playerType: VideoPlayerType = .VideoPlayerViewController

    @Lateinit var dataSource: any BroadcastsDataFetcher
    @Lateinit var store: AuthReduxStore

    lazy private var videoPlayer = YouTubePlayer()

    var playerFactory: YouTubeVideoPlayed {
        switch VideoListViewModel.playerType {
        case .oldVersionForIos8:
            return XCDYouTubeVideoPlayer8()
        case .AVPlayerViewController:
            return XCDYouTubeVideoPlayer()
        case .VideoPlayerViewController:
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
                VideoListRow(title: streamModel.snippet.title,
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

    func didLaunchStreamAction(indexPath: IndexPath, viewController: UIViewController) {
        videoPlayer.youtubeVideoPlayer = playerFactory

        switch indexPath.section {
        case 0:
            assert(false, "Incorrect section number")
        case 1:
            let broadcast = dataSource.getCurrent(for: indexPath.row)
            videoPlayer.playYoutubeID(broadcast.id, viewController: viewController)
        case 2:
            let broadcast = dataSource.getPast(for: indexPath.row)
            videoPlayer.playYoutubeID(broadcast.id, viewController: viewController)
        default:
            assert(false, "Incorrect section number")
        }
    }
}
