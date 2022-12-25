//
//  UpdateBroadcastView.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 25.12.2022.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//

import SwiftUI
import YTLiveStreaming

struct UpdateBroadcastView: View {
    @ObservedObject var viewModel: VideoDetailsViewModel
    
    var body: some View {
        VStack {
            BroadcastContentView(update: true, model: viewModel.broadcastModel)
        }
        .padding(.top, 40.0)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Update broadcast data")
                        .bold()
                        .foregroundColor(.black)
                }
            }
        }
    }
}

struct UpdateBroadcastDoneButton: View, Themeable {
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
