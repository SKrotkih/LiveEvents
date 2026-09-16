//
//  VideoControllerViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI
import YouTubeiOSPlayerHelper

@MainActor
final class VideoControllerViewModel: ObservableObject {
    private let player: YouTubePlayer

    init(videoId: String) {
        self.player = YouTubePlayer(videoId: videoId)
    }

    var playerView: YTPlayerView { player.playerView }

    func play() { player.play() }
    func pause() { player.pause() }
    func stop() { player.stop() }
    func start() { player.start() }
    func reverse() { player.reverse() }
    func forward() { player.forward() }
    func seek(toFraction fraction: Float) { player.seek(toFraction: fraction) }
}
