//
//  VideoDetailsViewModel.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 23.12.2022.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//
import Foundation
import YTLiveStreaming
import Combine

enum VideoDetailsActions {
    case playVideo
    case nothing
}

final class VideoDetailsViewModel: ObservableObject {
    var videoDetails: LiveBroadcastStreamModel
    
    @Published var actions: VideoDetailsActions = .nothing
    private var disposables = Set<AnyCancellable>()
    
    init(videoDetails: LiveBroadcastStreamModel) {
        self.videoDetails = videoDetails
        $actions
            .sink { userActivities in
                switch userActivities {
                case .playVideo:
                    // View is hundling by itself
                    break
                case .nothing:
                    break
                }
            }.store(in: &disposables)
    }
}
