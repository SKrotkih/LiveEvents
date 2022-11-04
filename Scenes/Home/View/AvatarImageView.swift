//
//  AvatarImageView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 9/17/22.
//

import Foundation
import SwiftUI

struct AvatarImageView: View {
    @EnvironmentObject var store: AuthReduxStore

    var body: some View {
        if let url = store.state.userSession?.profile.profilePicUrl {
            ProfileImageView(withURL: url.absoluteString)
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
    @EnvironmentObject var viewModel: HomeViewModel
    private let imageUrl: String

    init(withURL url: String) {
        self.imageUrl = url
    }

    var body: some View {
        if let avatarImage = viewModel.avatarImage {
            Image(uiImage: avatarImage)
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
            .clipShape(Circle())
            .overlay(Circle().stroke(.white, lineWidth: 1))
   }
}
