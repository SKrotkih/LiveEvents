//
//  VideoControllerView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI

struct VideoControllerView: View {
    @StateObject private var viewModel: VideoControllerViewModel
    @State private var seekFraction: Float = 0.0
    private let title: String

    init(videoId: String, title: String) {
        _viewModel = StateObject(wrappedValue: VideoControllerViewModel(videoId: videoId))
        self.title = title
    }

    var body: some View {
        VStack {
            Spacer().frame(height: 30.0)
            PlayerViewRepresentable(playerView: viewModel.playerView)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            Spacer()
            Slider(value: $seekFraction, in: 0...1, onEditingChanged: { editing in
                if !editing { viewModel.seek(toFraction: seekFraction) }
            })
            .padding(.horizontal)
            controlRow(["Play": viewModel.play, "Pause": viewModel.pause, "Stop": viewModel.stop])
            controlRow(["Start": viewModel.start, "Reverse": viewModel.reverse, "Forward": viewModel.forward])
            Spacer()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { ToolbarItem(placement: .topBarLeading) { BackButton() } }
        .ignoresSafeArea(edges: .bottom)
    }

    private func controlRow(_ buttons: KeyValuePairs<String, () -> Void>) -> some View {
        HStack {
            ForEach(Array(buttons), id: \.key) { title, action in
                Spacer()
                Button(title, action: action).foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        VideoControllerView(videoId: "M7lc1UVf-VE", title: "My test video")
    }
}
