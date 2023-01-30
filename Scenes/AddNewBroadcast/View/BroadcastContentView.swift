//
//  BroadcastContentView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 25.12.2022.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//

import Foundation
import SwiftUI

struct BroadcastContentView: View, Themeable {
    var update: Bool
    @State var model: BroadcastModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Form {
            Section(header: Text("Title").foregroundColor(addStreamSectionColor)) {
                TextField("Enter title of the broadcast video", text: $model.title)
                    .textFieldStyle(.roundedBorder)
            }
            Section(header: Text("Description").foregroundColor(addStreamSectionColor)) {
                TextField("Enter description of the broadcast video", text: $model.description)
                    .textFieldStyle(.roundedBorder)
            }
            Section(header: Text("Scheduled time:").foregroundColor(addStreamSectionColor)) {
                if update {
                    DatePicker("Start", selection: $model.scheduledStartTime)
                        .padding()
                    DatePicker("End", selection: $model.scheduledEndTime)
                        .padding()
                } else {
                    DatePicker("Start", selection: $model.scheduledStartTime, in: Date()...)
                        .padding()
                    DatePicker("End", selection: $model.scheduledEndTime, in: model.scheduledStartTime...)
                        .padding()
                }
            }
            Section {
                Toggle("Is it child-directed?", isOn: $model.selfDeclaredMadeForKids)
                    .tint(.red)
                Toggle("Does this broadcast should start automatically when you start streaming video on the bound live stream?", isOn: $model.enableAutoStart)
                    .tint(.red)
                Toggle("Does this broadcast should stop automatically around one minute after the channel owner stops streaming video on the bound video stream?", isOn: $model.enableAutoStop)
                    .tint(.red)
                Toggle("Do you send captions, via HTTP POST, to an ingestion URL associated with your live stream?", isOn: $model.enableClosedCaptions)
                    .tint(.red)
                Toggle("Can viewers access DVR controls while watching the video?", isOn: $model.enableDvr)
                    .tint(.red)
                Toggle("Can be played the broadcast video in an embedded player?", isOn: $model.enableEmbed)
                    .tint(.red)
                Toggle("Will the broadcast automatically start recording after the event's status changes to live?", isOn: $model.recordFromStart)
                    .tint(.red)
                Toggle("Is the monitor stream enabled for the broadcast?", isOn: $model.enableMonitorStream)
                    .tint(.red)
                if model.enableMonitorStream {
                    Section(header: Text("Length of the live broadcast delay in MS").foregroundColor(addStreamSectionColor)) {
                        TextField("Enter delay value in MS", value: $model.broadcastStreamDelayMs, formatter: NumberFormatter())
                            .textFieldStyle(.roundedBorder)
                    }
                }
                Toggle("Is this stream common for broadcasters to reuse the same stream for many different broadcasts?", isOn: $model.isReusable)
                    .tint(.red)
            }
            Section {
                Picker("Select a privacy status", selection: $model.privacyStatus) {
                    ForEach(["public", "private", "unlisted"], id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
}
