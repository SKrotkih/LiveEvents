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
            .loadingIndicator(viewModel.isOperationInProgress)
            .padding(.top, 30.0)
            .navigationBarTitle(Text("Schedule a new live video"), displayMode: .inline)
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton(),
                                trailing: DoneButton())
    }

    struct NewStreamContentView: View {
        @Binding var model: NewStream

        var body: some View {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter title new live video", text: $model.title)
                        .textFieldStyle(.roundedBorder)
                }
                Section(header: Text("Description")) {
                    TextField("Enter short description of the new live video", text: $model.description)
                        .textFieldStyle(.roundedBorder)
                }
                Section(header: Text("Run after:")) {
                    decimalTextField("Hours", $model.hours)
                    decimalTextField("Minutes", $model.minutes)
                    decimalTextField("Seconds", $model.seconds)
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
        @Environment(\.presentationMode) var presentationMode
        @State var showingAlert = false

        var body: some View {
            HStack {
                Button(action: {
                    showingAlert = viewModel.verification()
                }, label: {
                    HStack {
                        Text("Done")
                            .foregroundColor(.white)
                    }
                })
                .alert("Do you realy want to create a new Live broadcast video?", isPresented: $showingAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("OK") {
                        viewModel.createNewStream {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
}
