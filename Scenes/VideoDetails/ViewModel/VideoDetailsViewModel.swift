//
//  VideoDetailsViewModel.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 23.12.2022.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//
import Foundation
import YTLiveStreaming

final class VideoDetailsViewModel: ObservableObject {
    var videoDetails: LiveBroadcastStreamModel
    
    init(videoDetails: LiveBroadcastStreamModel) {
        self.videoDetails = videoDetails
    }

    
    
}
