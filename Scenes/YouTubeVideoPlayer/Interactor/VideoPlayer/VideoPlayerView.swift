//
//  VideoPlayerView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 10/20/22.
//
import SwiftUI
import AVKit

struct VideoPlayerView: View {
    // "https://bit.ly/swswift"
    let videoId: String

    var body: some View {
        if let videoUrl = URL(string: videoId) {
            //        if let testVideoUrl = Bundle.main.url(forResource: "video", withExtension: "mp4") {
            VideoPlayer(player: AVPlayer(url: videoUrl))
                .frame(height: 400)
        }
    }
}
