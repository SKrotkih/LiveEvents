//
//  VideoDetailsView.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 23.12.2022.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//
import SwiftUI

struct VideoDetailsView: View {
    var viewModel: VideoDetailsViewModel
    
    private var contentView: some View {
        VStack {

//            NavigationLink(destination: VideoControllerView(videoId: viewModel.videoDetails.id,
//                                                            title: viewModel.videoDetails.snippet.title)) {
//            }

            Spacer()
                .frame(height: 30.0)

            Button("Play") {
                
            }
        }
    }

    var body: some View {
        contentView
            .navigationBar(title: viewModel.videoDetails.snippet.title)
            .navigationBarItems(leading: BackButton())
    }
}
