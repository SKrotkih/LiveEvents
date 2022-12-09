//
//  VideoPlayerFactory.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 09.12.2022.
//
import Foundation

struct VideoPlayerFactory {
    enum VideoPlayerType {
        case defaultVideoPlayer
        case oldVersionForIos8
        case AVPlayerViewController
    }

    // Default value of the used video player
    private static let playerType: VideoPlayerType = .defaultVideoPlayer

    lazy private var videoPlayer = YouTubePlayer()

    var playerFactory: YouTubeVideoPlayed {
        switch VideoPlayerFactory.playerType {
        case .oldVersionForIos8:
            return XCDYouTubeVideoPlayer8()
        case .AVPlayerViewController:
            return XCDYouTubeVideoPlayer()
        case .defaultVideoPlayer:
            return YTVideoPlayer()
        }
    }
}
