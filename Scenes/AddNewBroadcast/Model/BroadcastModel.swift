//
//  BroadcastModel.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 24.03.2021.
//
import Foundation
import YTLiveStreaming

struct BroadcastModel {
    var title: String = ""                  // snippet.title
    var scheduledStartTime: Date = Date()   // snippet.scheduledStartTime
    var description: String = ""            // snippet.description
    var scheduledEndTime: Date = Date()     // snippet.scheduledEndTime
    // selfDeclaredMadeForKids allows the channel owner to designate the broadcast as being child-directed
    var selfDeclaredMadeForKids: Bool = false // status.selfDeclaredMadeForKids
    // Indicates whether this broadcast should start automatically when you start streaming video on the bound live stream
    var enableAutoStart: Bool = false       // contentDetails.enableAutoStart
    // Indicates whether this broadcast should stop automatically around one minute after the channel owner stops streaming video on the bound video stream.
    var enableAutoStop: Bool = false        // contentDetails.enableAutoStop
    // = true - closedCaptionsHttpPost: You will send captions, via HTTP POST, to an ingestion URL associated with your live stream.
    // - false - closedCaptionsDisabled: Closed captions are disabled for the live broadcast.
    var enableClosedCaptions: Bool = false    // contentDetails.enableClosedCaptions
    // This setting determines whether viewers can access DVR controls while watching the video. DVR controls enable the viewer to control the video playback experience by pausing, rewinding, or fast forwarding content. The default value for this property is true.
    var enableDvr: Bool = true             // contentDetails.enableDvr
    //  This setting indicates whether the broadcast video can be played in an embedded player. If you choose to archive the video (using the enableArchive property), this setting will also apply to the archived video.
    var enableEmbed: Bool = false           // contentDetails.enableEmbed
    //  This setting indicates whether YouTube will automatically start recording the broadcast after the event's status changes to live.
    var recordFromStart: Bool = true       // contentDetails.recordFromStart
    //  This value determines whether the monitor stream is enabled for the broadcast. If the monitor stream is enabled, then YouTube will broadcast the event content on a special stream intended only for the broadcaster's consumption. The broadcaster can use the stream to review the event content and also to identify the optimal times to insert cuepoints.
    var enableMonitorStream: Bool = false   // contentDetails.monitorStream.enableMonitorStream
    //  If you have set the enableMonitorStream property to true, then this property determines the length of the live broadcast delay.
    var broadcastStreamDelayMs: Int = 0     // contentDetails.monitorStream.broadcastStreamDelayMs
    //
    var privacyStatus: String = "unlisted"    // status.privacyStatus ("public", "private", "unlisted")
    //
    var isReusable: Bool = false            // For LiveStream insert used. Indicates whether the stream is reusable, which means that it can be bound to multiple broadcasts. It is common for broadcasters to reuse the same stream for many different broadcasts if those broadcasts occur at different times.
    
    init() {
    }
    
    init(model: LiveBroadcastStreamModel) {
        title = model.snippet.title
        scheduledStartTime = model.snippet.scheduledStartTime ?? Date()
        description = model.snippet.description
        scheduledEndTime = model.snippet.scheduledEndTime ?? Date()
        selfDeclaredMadeForKids = model.status?.selfDeclaredMadeForKids ?? false
        enableAutoStart = model.contentDetails?.enableAutoStart ?? false
        enableAutoStop = model.contentDetails?.enableAutoStop ?? false
        enableClosedCaptions = model.contentDetails?.enableClosedCaptions ?? false
        enableDvr = model.contentDetails?.enableDvr  ?? false
        enableEmbed = model.contentDetails?.enableEmbed  ?? false
        recordFromStart = model.contentDetails?.recordFromStart ?? false
        enableMonitorStream = model.contentDetails?.monitorStream.enableMonitorStream ?? false
        broadcastStreamDelayMs = model.contentDetails?.monitorStream.broadcastStreamDelayMs ?? 0
        privacyStatus = model.status?.privacyStatus ?? "unlisted"
        isReusable = false
    }
}
