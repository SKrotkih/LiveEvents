//
//  VideoListViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import YTLiveStreaming
import RxSwift
import Combine

enum VideoPlayerType {
    case oldVersionForIos8
    case AVPlayerViewController
    case VideoPlayerViewController
}

class VideoListViewModel: VideoListViewModelOutput {
    // Default value of the used video player
    private static let playerType: VideoPlayerType = .VideoPlayerViewController

    @Lateinit var store: AuthStore
    @Lateinit var dataSource: BroadcastsDataFetcher

    var errorPublisher = PassthroughSubject<String, Never>()
    private let disposeBag = DisposeBag()

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

    func didOpenViewAction() {
        configure()
        dataSource.loadData()
    }

    func didUserLogOutAction() {
        store.stateDispatch(action: .logOut)
    }

    func didCloseViewAction() {
        Router.openMainScreen()
    }

    private func configure() {
        rxData
            .subscribe(onNext: { data in
                var message = ""
                data.forEach { item in
                    if let errorMessage = item.error {
                        message += errorMessage + "\n"
                    }
                }
                if !message.isEmpty {
                    self.errorPublisher.send(message)
                }
            }).disposed(by: disposeBag)
    }

    func createBroadcast() {
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

// MARK: - VideoListViewModelInput protocol implementation

extension VideoListViewModel: VideoListViewModelInput {
    var rxData: PublishSubject<[SectionModel]> {
        return dataSource.rxData
    }
}
