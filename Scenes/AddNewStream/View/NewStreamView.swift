//
//  NewStreamView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 10/14/22.
//

import SwiftUI

struct NewStreamView: View {
    @EnvironmentObject var viewModel: NewStreamViewModel

    var body: some View {
        if !viewModel.error.isEmpty {
            VStack {
                Spacer()
                    .frame(height: 40.0)
                Text(viewModel.error)
                    .foregroundColor(.red)
            }
        }
        NewStreamContentView(model: $viewModel.model)
            .loadingIndicator(viewModel.isAvatarDownloading)
            .padding(.top, 30.0)
            .navigationBarTitle(Text("Schedule a new live video"), displayMode: .inline)
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton(),
                                trailing: DoneButton())
            .onAppear {
            }
    }

    struct NewStreamContentView: View {
        @Binding var model: NewStream

        var body: some View {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter title new live video", text: $model.title)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
                Section(header: Text("Description")) {
                    TextField("Enter short description of the new live video", text: $model.description)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
                Section(header: Text("Run after:")) {
                    TextField("Hours", text: $model.hours)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    TextField("Minutes", text: $model.minutes)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    TextField("Seconds", text: $model.seconds)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
                Section(header: Text("Run at:")) {
                    Text(model.runAt)
                    DatePicker("Date", selection: $model.date, displayedComponents: .date)
                }
            }
        }
    }

    struct DoneButton: View {
        @EnvironmentObject var viewModel: NewStreamViewModel

        var body: some View {
            HStack {
                Button(action: {

//                    Alert.showConfirmCancel(
//                        "YouTube Live Streaming API",
//                        message: "Do you realy want to create a new Live broadcast video?",
//                        onConfirm: {
//                            self.viewModel.createBroadcast()
//                        }
//                    )

                    viewModel.createNewStream()
                }, label: {
                    HStack {
                        Text("Done")
                            .foregroundColor(.white)
                    }
                })
            }
        }
    }
}
