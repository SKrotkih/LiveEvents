//
//  AvatarImageView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 9/17/22.
//
import Foundation
import SwiftUI

struct AvatarImageView: View, Themeable {
    @EnvironmentObject var store: AuthReduxStore
    @Environment(\.colorScheme) var colorScheme
    @State var profilePicUrl: URL?
    
    private var contentView: some View {
        VStack {
            if let url = profilePicUrl {
                ProfileImageView(withURL: url.absoluteString)
            } else {
                PlaceholderView()
            }
        }
    }

    var body: some View {
        contentView
            .onAppear {
                Task {
                    if let userSession = await store.state.userSession {
                        profilePicUrl = userSession.profile?.profilePicUrl
                    }
                }
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
                    viewModel.downloadAvatarImage(url: imageUrl)
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
