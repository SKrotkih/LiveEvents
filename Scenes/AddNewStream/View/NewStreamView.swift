//
//  NewStreamView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 10/14/22.
//

import SwiftUI

struct NewStreamView: View {
    @EnvironmentObject var viewModel: NewStreamViewModel
    @State var localError = ""

    var body: some View {
        if !viewModel.error.isEmpty {
            textError(viewModel.error)
        }
        if !localError.isEmpty {
            textError(localError)
        }
        NewStreamContentView(model: $viewModel.model)
            .loadingIndicator(viewModel.isOperationInProgress)
            .padding(.top, 30.0)
            .navigationBar(title: "Schedule a new live video")
            .navigationBarItems(leading: BackButton(),
                                trailing: DoneButton(errorMessage: $localError))
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
        @Binding var model: NewStream
        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            Form {
                Section(header: Text("Title").foregroundColor(addStreamSectionColor)) {
                    TextField("Enter title new live video", text: $model.title)
                        .textFieldStyle(.roundedBorder)
                }
                Section(header: Text("Description").foregroundColor(addStreamSectionColor)) {
                    TextField("Enter short description of the new live video", text: $model.description)
                        .textFieldStyle(.roundedBorder)
                }
                Section(header: Text("Run after:").foregroundColor(addStreamSectionColor)) {
                    decimalTextField("Hours", $model.hours)
                    decimalTextField("Minutes", $model.minutes)
                    decimalTextField("Seconds", $model.seconds)
                }
                Section(header: Text("Run at:").foregroundColor(addStreamSectionColor)) {
                    Text(model.runAt)
                    DatePicker("Date", selection: $model.date, displayedComponents: .date)
                }
            }
        }
    }

    struct DoneButton: View, Themeable {
        @EnvironmentObject var viewModel: NewStreamViewModel
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
