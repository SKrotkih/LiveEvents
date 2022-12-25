//
//  NewBroadcastView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 10/14/22.
//

import SwiftUI

struct NewBroadcastView: View {
    @EnvironmentObject var viewModel: NewBroadcastViewModel
    @State var localError = ""

    var body: some View {
        if !viewModel.error.isEmpty {
            textError(viewModel.error)
        }
        if !localError.isEmpty {
            textError(localError)
        }
        VStack {
            NewStreamContentView(model: $viewModel.model)
        }
        .padding(.top, 40.0)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton(),
                            trailing: DoneButton(errorMessage: $localError))
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Schedule a new live video")
                        .bold()
                        .foregroundColor(.black)
                }
            }
        }
        .loadingIndicator(viewModel.isOperationInProgress)
    }

    private func textError(_ message: String) -> some View {
        VStack {
            Spacer()
                .frame(height: 40.0)
            Text(message)
                .foregroundColor(.red)
        }
    }

    struct NewStreamContentView: View, Themeable {
        @EnvironmentObject var viewModel: NewBroadcastViewModel
        @Binding var model: NewBroadcastModel
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
                    DatePicker("Start", selection: $model.scheduledStartTime, in: Date()...)
                        .padding()
                    DatePicker("End", selection: $model.scheduledEndTime, in: model.scheduledStartTime...)
                        .padding()
                }
                Section() {
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
                Section() {
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

    struct DoneButton: View, Themeable {
        @EnvironmentObject var viewModel: NewBroadcastViewModel
        @Environment(\.presentationMode) var presentationMode
        @Environment(\.colorScheme) var colorScheme
        @Binding var errorMessage: String
        @State var showingAlert = false

        var body: some View {
            HStack {
                Button(action: {
                    showingAlert = viewModel.verification()
                }, label: {
                    HStack {
                        Text("Done")
                            .foregroundColor(doneButtonColor)
                    }
                })
                .alert("Do you realy want to create a new Live broadcast video?", isPresented: $showingAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("OK") {
                        Task {
                            do {
                                try await viewModel.createNewStream()
                                presentationMode.wrappedValue.dismiss()
                            } catch let error {
                                errorMessage = (error as! LVError).message()
                            }
                        }
                    }
                }
            }
        }
    }
}
