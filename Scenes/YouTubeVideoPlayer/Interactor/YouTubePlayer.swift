//
//  YouTubePlayer.swift
//  LiveEvents
//
//  Swift wrapper over YTPlayerView (youtube-ios-player-helper), replacing the old
//  Objective-C VideoPlayer.m and its bridging header.
//

import UIKit
import YouTubeiOSPlayerHelper

final class YouTubePlayer: NSObject {
    let playerView = YTPlayerView()

    init(videoId: String) {
        super.init()
        playerView.delegate = self
        // Full parameter list: https://developers.google.com/youtube/player_parameters
        let playerVars: [String: Any] = [
            "controls": 0,
            "playsinline": 1,
            "autohide": 1,
            "showinfo": 0,
            "modestbranding": 1
        ]
        playerView.load(withVideoId: videoId, playerVars: playerVars)
    }

    func play() { playerView.playVideo() }
    func pause() { playerView.pauseVideo() }
    func stop() { playerView.stopVideo() }
    func start() { playerView.seek(toSeconds: 0, allowSeekAhead: true) }

    func reverse() {
        playerView.currentTime { [weak playerView] time, _ in
            playerView?.seek(toSeconds: time - 30.0, allowSeekAhead: true)
        }
    }

    func forward() {
        playerView.currentTime { [weak playerView] time, _ in
            playerView?.seek(toSeconds: time + 30.0, allowSeekAhead: true)
        }
    }

    /// `fraction` in 0...1 of the total duration.
    func seek(toFraction fraction: Float) {
        playerView.duration { [weak playerView] duration, _ in
            playerView?.seek(toSeconds: Float(duration) * fraction, allowSeekAhead: true)
        }
    }
}

extension YouTubePlayer: YTPlayerViewDelegate {
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        print("Player state changed: \(state.rawValue)")
    }
}
