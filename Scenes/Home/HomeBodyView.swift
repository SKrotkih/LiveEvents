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
    @EnvironmentObject var signInViewModel: GoogleSignInViewModel

    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 15.0) {
                Text(LogInSession.userFullName ?? "???")
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
                Router.showVideoListScreen()
            }, label: {
                Text("Video List")
                    .padding()
                    .frame(width: 130.0)
                    .foregroundColor(.blue)
            })
            Spacer()
            Button(action: {
                LogInSession.logOut()
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
}

struct AvatarImageView: View {
    var body: some View {
        if let url = LogInSession.userProfilePictureUrl {
            ProfileImageView(withURL: url.absoluteString)
        } else {
            PlaceholderView()
        }
    }
}

struct PlaceholderView: View {
    var body: some View {
        Image(systemName: "person")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30.0, height: 30.0)
            .padding(.trailing, 30.0)
            .cornerRadius(15.0)
    }
}

struct ProfileImageView: View {
    @ObservedObject var imageLoader: ImageLoader
    @State var image: UIImage = UIImage()

    init(withURL url: String) {
        imageLoader = ImageLoader(urlString: url)
    }

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30.0, height: 30.0)
            .cornerRadius(15.0)
            .padding(.trailing, 30.0)
            .onReceive(imageLoader.didChange) { data in
                self.image = UIImage(data: data) ?? UIImage()
            }
    }
}

struct HomeBodyView_Previews: PreviewProvider {
    static var previews: some View {
        HomeBodyView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
            .previewDisplayName("iPhone 12 Pro")
    }
}
