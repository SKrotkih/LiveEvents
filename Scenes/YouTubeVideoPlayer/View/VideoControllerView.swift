//
//  VideoPlayerBodyView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI

struct VideoControllerView: View {
    @State private var seekToSeconds: Float = 0.0
    @State private var isSliderChanged = false {
        didSet {
            viewModel.seekToSeconds(seekToSeconds)
        }
    }
    private var viewModel: VideoPlayerControlled
    private let title: String
    private var navigateController: NavicationObservable
    private var playerView: PlayerViewRepresentable {
        viewModel.playerView
    }

    init(videoId: String, title: String) {
        self.title = title
        viewModel = VideoControllerViewModel(videoId: videoId)
        navigateController = NavicationObservable()
    }

    var body: some View {
        VStack {
            Spacer()
                .frame(height: 30.0)
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
                Button("Play") { viewModel.play() }
                    .foregroundColor(.gray)
                Spacer()
                Button("Pause") { viewModel.pause() }
                    .foregroundColor(.gray)
                Spacer()
                Button("Stop") { viewModel.stop() }
                    .foregroundColor(.gray)
                Spacer()
            }
            HStack {
                Spacer()
                Button("Start") { viewModel.start() }
                    .foregroundColor(.gray)
                Spacer()
                Button("Reverse") { viewModel.reverse() }
                    .foregroundColor(.gray)
                Spacer()
                Button("Forward") { viewModel.forward() }
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
