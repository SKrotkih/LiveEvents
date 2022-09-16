//
//  HomeBodyView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI
import Combine

/// SwiftUI content view for the Home screen
struct HomeBodyView: View {
    @EnvironmentObject var store: AuthStore
    @EnvironmentObject var viewModel: HomeBodyViewModel

    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 15.0) {
                Text(store.state.userSession?.profile.fullName ?? "")
                    .foregroundColor(.secondary)
                    .lineLimit(0)
                    .padding(.leading, 30.0)
                Spacer()
                AvatarImageView()
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

struct AvatarImageView: View {
    @EnvironmentObject var store: AuthStore
    @EnvironmentObject var viewModel: HomeBodyViewModel

    var body: some View {
        if let url = store.state.userSession?.profile.profilePicUrl {
            ProfileImageView(withURL: url.absoluteString, viewModel: viewModel)
        } else {
            PlaceholderView()
        }
    }
}

struct PlaceholderView: View {
    var body: some View {
        Image(systemName: "person")
            .avatarStyle()
    }
}

struct ProfileImageView: View {
    @ObservedObject private var viewModel: HomeBodyViewModel
    private let imageUrl: String

    init(withURL url: String, viewModel: HomeBodyViewModel) {
        self.imageUrl = url
        self.viewModel = viewModel
    }

    var body: some View {
        if let avatarImave = viewModel.avatarImave {
            Image(uiImage: avatarImave)
                .avatarStyle()
        } else {
            PlaceholderView()
                .onAppear {
                    viewModel.downloadImage(url: imageUrl)
                }
        }
    }
}

extension Image {
    func avatarStyle() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30.0, height: 30.0)
            .cornerRadius(15.0)
            .padding(.trailing, 30.0)
   }
}

struct HomeBodyView_Previews: PreviewProvider {
    static var previews: some View {
        let environment = NetworkService()
        let store = Store(initialState: .init(userSession: nil), reducer: authReducer, environment: environment)
        HomeBodyView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
            .previewDisplayName("iPhone 12 Pro")
            .environmentObject(store)
    }
}
