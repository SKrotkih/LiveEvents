//
//  VideoPlayerFactory.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 09.12.2022.
//
import Foundation

/// Single place to choose the YouTube player implementation.
/// Only the iframe player (youtube-ios-player-helper) is left: XCDYouTubeKit, which extracted
/// direct stream URLs for AVPlayer, is archived and no longer works with YouTube.
struct VideoPlayerFactory {
    var playerFactory: YouTubeVideoPlayed {
        YTVideoPlayer()
    }
}
