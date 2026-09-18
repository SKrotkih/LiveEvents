import SwiftUI
import YouTubeiOSPlayerHelper

struct PlayerViewRepresentable: UIViewRepresentable {
    let playerView: YTPlayerView
    func makeUIView(context: Context) -> YTPlayerView { playerView }
    func updateUIView(_ uiView: YTPlayerView, context: Context) {}
}
