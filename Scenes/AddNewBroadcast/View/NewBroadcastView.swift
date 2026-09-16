//
//  NewBroadcastView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 10/14/22.
//
import SwiftUI

struct NewBroadcastView: View {
    @EnvironmentObject var viewModel: NewBroadcastViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var localError = ""
    @State private var showingConfirm = false

    var body: some View {
        VStack {
            if !viewModel.error.isEmpty { textError(viewModel.error) }
            if !localError.isEmpty { textError(localError) }
            BroadcastContentView(update: false, model: $viewModel.model)
        }
        .navigationBar(title: "Schedule a new live video")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { BackButton() }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { showingConfirm = viewModel.verification() }
            }
        }
        .loadingIndicator(viewModel.isOperationInProgress)
        .alert("Do you really want to create a new live broadcast video?", isPresented: $showingConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                Task {
                    do {
                        try await viewModel.createNewStream()
                        dismiss()
                    } catch {
                        localError = error.localizedDescription
                    }
                }
            }
        }
    }

    private func textError(_ message: String) -> some View {
        Text(message)
            .foregroundColor(.red)
            .padding(.top, 40.0)
    }
}
