//
//  AvatarImageView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 9/17/22.
//

import Foundation
import SwiftUI

struct AvatarImageView<ViewModel>: View where ViewModel: HomeViewModelInterface {
    @EnvironmentObject var store: AuthReduxStore
    @ObservedObject var viewModel: ViewModel

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

struct ProfileImageView<ViewModel>: View where ViewModel: HomeViewModelInterface {
    @ObservedObject private var viewModel: ViewModel
    private let imageUrl: String

    init(withURL url: String, viewModel: ViewModel) {
        self.imageUrl = url
        self.viewModel = viewModel
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
