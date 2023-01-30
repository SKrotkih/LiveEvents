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
        Spacer()
            .frame(height: 55.0)
        BroadcastContentView(update: false, model: viewModel.model)
            .navigationBar(title: "Schedule a new live video")
            .navigationBarItems(leading: BackButton(),
                                trailing: InsertBroadcastDoneButton(errorMessage: $localError))
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

    struct InsertBroadcastDoneButton: View, Themeable {
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
