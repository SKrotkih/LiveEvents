//
//  AvatarImageView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 9/17/22.
//
import SwiftUI

struct AvatarImageView: View {
    @EnvironmentObject var viewModel: MenuViewModel

    var body: some View {
        AsyncImage(url: viewModel.profilePicUrl) { phase in
            if let image = phase.image {
                image.avatarStyle()
            } else {
                PlaceholderView()
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
