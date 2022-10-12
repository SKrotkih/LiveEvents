//
//  VideoPlayerBodyView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI

typealias PlayerInteractor = VideoPlayerControlled

struct VideoControllerView: View {
    @State private var seekToSeconds: Float = 0.0
    @State private var isSliderChanged = false {
        didSet {
            interactor.seekToSeconds(seekToSeconds)
        }
    }
    let title: String
    var interactor: PlayerInteractor
    var navigateController: NavicationObservable
    var playerView: PlayerViewRepresentable

    init(videoId: String, title: String) {
        self.title = title
        let videoPlayer = VideoPlayer(videoId: videoId)
        interactor = VideoPlayerInteractor(videoPlayer: videoPlayer!)
        navigateController = NavicationObservable()
        playerView = PlayerViewRepresentable(playerView: videoPlayer!.playerView)
    }

    var body: some View {
        VStack {
            playerView
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            Spacer()
            HStack {
                Spacer()
                Slider(
                    value: $seekToSeconds,
                    in: 0...100,
                    onEditingChanged: { editing in
                        isSliderChanged = editing
                    }
                )
                Spacer()
            }
            HStack {
                Spacer()
                Button("Play") { interactor.play() }
                    .foregroundColor(.gray)
                Spacer()
                Button("Pause") { interactor.pause() }
                    .foregroundColor(.gray)
                Spacer()
                Button("Stop") { interactor.stop() }
                    .foregroundColor(.gray)
                Spacer()
            }
            HStack {
                Spacer()
                Button("Start") { interactor.start() }
                    .foregroundColor(.gray)
                Spacer()
                Button("Reverse") { interactor.reverse() }
                    .foregroundColor(.gray)
                Spacer()
                Button("Forward") { interactor.forward() }
                    .foregroundColor(.gray)
                Spacer()
            }
            Spacer()
        }
        .navigationBarTitle(Text(self.title), displayMode: .inline)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
    }
}

struct VideoPlayerContentView_Previews: PreviewProvider {
    static var previews: some View {
        VideoControllerView(videoId: "M7lc1UVf-VE", title: "My test video")
    }
}
