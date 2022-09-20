//
//  HomeView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI
import Combine

/// SwiftUI content view for the Home screen
struct HomeView<ViewModel>: View where ViewModel: HomeViewModelInterface {
    @EnvironmentObject var store: AuthStore
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 15.0) {
                Text(store.state.userSession?.profile.fullName ?? "")
                    .foregroundColor(.secondary)
                    .lineLimit(0)
                    .padding(.leading, 30.0)
                Spacer()
                AvatarImageView(viewModel: viewModel)
            }
            .frame(height: 30.0)
            Spacer()
            Image("icon-logo")
                .resizable()
                .scaledToFit()
            Spacer()
            Button(action: {
                openVideoListScreen()
            }, label: {
                Text("Video List")
                    .padding()
                    .frame(width: 130.0)
                    .foregroundColor(.blue)
            })
            Spacer()
            Button(action: {
                logOut()
            }, label: {
                Text("Log Out")
                    .padding()
                    .frame(width: 130.0)
                    .foregroundColor(.red)
            })
            Spacer()
        }
        .padding(.top, 80.0)
        .padding(.bottom, 80.0)
    }

    private func openVideoListScreen() {
        Router.openVideoListScreen()
    }

    private func logOut() {
        store.stateDispatch(action: .logOut)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(initialState: .init(userSession: nil),
                          reducer: authReducer,
                          environment: NetworkService())
        HomeView(viewModel: HomeViewModel())
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
            .previewDisplayName("iPhone 12 Pro")
            .environmentObject(store)
    }
}
