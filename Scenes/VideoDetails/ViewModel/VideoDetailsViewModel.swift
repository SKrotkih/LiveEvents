//
//  VideoDetailsViewModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 23.12.2022.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//
import Foundation
import YTLiveStreaming
import Combine

enum VideoDetailsActions {
    case playVideo
    case update
    case nothing
}

final class VideoDetailsViewModel: ObservableObject {
    private var model: LiveBroadcastStreamModel

    @Published var actions: VideoDetailsActions = .nothing
    private var disposables = Set<AnyCancellable>()

    var broadcastModel: BroadcastModel { BroadcastModel(model: model) }

    init(videoDetails: LiveBroadcastStreamModel) {
        self.model = videoDetails
        $actions
            .sink { userActivities in
                switch userActivities {
                case .playVideo, .update:
                    // View is hundling by itself
                    break
                case .nothing:
                    break
                }
            }.store(in: &disposables)
    }

    var title: String { model.snippet.title }
    // The ID that YouTube assigns to uniquely identify the broadcast.
    var broadcastId: String { model.id }

    var lifeCycleStatus: String? { model.status?.lifeCycleStatus }
    var channelId: String { model.snippet.channelId }       // The ID that YouTube uses to uniquely identify the channel that is publishing the broadcast.
    var description: String { model.snippet.description }     // The broadcast's description. As with the title, you can set this field by modifying the broadcast resource or by setting the description field of the corresponding video resource.

    var publishedAt: String { model.snippet.publishedAt.fullDateFormat }     // The date and time that the broadcast was added to YouTube's live broadcast schedule. The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format.
    var scheduledStartTime: String? { model.snippet.scheduledStartTime?.fullDateFormat } // The date and time that the broadcast is scheduled to start. The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format. Creator Studio supports the ability to create a broadcast without scheduling a start time. In this case, the broadcast starts whenever the channel owner starts streaming. For these broadcasts, the datetime value corresponds to UNIX time zero, and this value cannot be changed via the API or in Creator Studio.
    var scheduledEndTime: String? { model.snippet.scheduledEndTime?.fullDateFormat }   // The date and time that the broadcast is scheduled to end. The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format. If a liveBroadcast resource does not specify a value for this property, then the broadcast is scheduled to continue indefinitely. Similarly, if you do not specify a value for this property, then YouTube treats the broadcast as if it will go on indefinitely.
    var actualStartTime: String? { model.snippet.actualStartTime?.fullDateFormat }    // The date and time that the broadcast actually started. This information is only available once the broadcast's state is live. The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format.
    var actualEndTime: String? { model.snippet.actualEndTime?.fullDateFormat }      // The date and time that the broadcast actually ended. This information is only available once the broadcast's state is complete. The value is specified in ISO 8601 (YYYY-MM-DDThh:mm:ss.sZ) format.
    var thumbnailsDef: (String?, width: CGFloat, height: CGFloat) {
        let url = model.snippet.thumbnails.def.url
        let w = model.snippet.thumbnails.def.width
        let h = model.snippet.thumbnails.def.height
        return (url, CGFloat(w), CGFloat(h))
    }
    var thumbnailsHigh: (String?, width: CGFloat, height: CGFloat) {
        let url = model.snippet.thumbnails.height.url
        let w = model.snippet.thumbnails.height.width
        let h = model.snippet.thumbnails.height.height
        return (url, CGFloat(w), CGFloat(h))
    }
}
