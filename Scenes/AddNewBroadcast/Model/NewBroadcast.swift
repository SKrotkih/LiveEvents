//
//  NewBroadcast.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 24.03.2021.
//
import Foundation

struct NewBroadcastModel {
    var hours = ""
    var minutes = ""
    var seconds = ""
    var date = Date()
    var title: String = ""                  // snippet.title
    var startDateTime: Date = Date()        // snippet.scheduledStartTime
    var description: String = ""            // snippet.description
    var endDateTime: Date = Date()          // snippet.scheduledEndTime
    var selfDeclaredMadeForKids: String = "" // status.selfDeclaredMadeForKids
    var enableAutoStart: Bool = false       // contentDetails.enableAutoStart
    var enableAutoStop: Bool = false        // contentDetails.enableAutoStop
    var enableClosedCaptions: Bool = false  // contentDetails.enableClosedCaptions
    var enableDvr: Bool = false             // contentDetails.enableDvr
    var enableEmbed: Bool = false           // contentDetails.enableEmbed
    var recordFromStart: Bool = false       // contentDetails.recordFromStart
    var enableMonitorStream: Bool = false   // contentDetails.monitorStream.enableMonitorStream
    var broadcastStreamDelayMs: Int = 0     // contentDetails.monitorStream.broadcastStreamDelayMs
    var privacyStatus: String = "public"    // status.privacyStatus ("public"
    var isReusable: Bool = false            // For LiveStream insert used. Indicates whether the stream is reusable, which means that it can be bound to multiple broadcasts. It is common for broadcasters to reuse the same stream for many different broadcasts if those broadcasts occur at different times.
}
