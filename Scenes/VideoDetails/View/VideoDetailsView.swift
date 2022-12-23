//
//  VideoDetailsView.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 23.12.2022.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//
import SwiftUI

struct VideoDetailsView: View, Themeable {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: VideoDetailsViewModel
    @State private var isShowingVideoPlayer = false
    
    private var contentView: some View {
        VStack {
            Spacer()
                .frame(height: 60.0)
            HStack {
                Text("Title")
                    .foregroundColor(.gray)
                    .padding(.trailing, 5.0)
                Text(viewModel.videoDetails.snippet.title)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.leading, 20.0)
            .padding(.bottom, 30.0)

            Spacer()
            
            PlayVideoButton(title: "Play",
                            action: $viewModel.actions,
                            runAction: .playVideo)
            .padding(.bottom, 60.0)
        }
    }

    var body: some View {
        NavigationLink(destination: VideoControllerView(videoId: viewModel.videoDetails.id,
                                                        title: viewModel.videoDetails.snippet.title),
                       isActive: $isShowingVideoPlayer) { EmptyView() }
        contentView
            .navigationBar(title: viewModel.videoDetails.snippet.title)
            .navigationBarItems(leading: BackButton())
            .onChange(of: viewModel.actions) { newValue in
                isShowingVideoPlayer = newValue == .playVideo
            }
            .foregroundColor(.red)
    }
}

/// Play Video Button
struct PlayVideoButton: View, Themeable {
    @Environment(\.colorScheme) var colorScheme

    var title: String
    @Binding var action: VideoDetailsActions
    let runAction: VideoDetailsActions

    var body: some View {
        Button(action: {
            action = runAction
        }, label: {
            Text(title)
                .padding()
                .foregroundColor(videoListButtonColor)
        })
        .style(appStyle: .redBorderButton)
        .frame(width: 130.0, height: 20.0)
    }
}
