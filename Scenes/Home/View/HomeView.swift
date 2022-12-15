//
//  HomeView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI
import Combine
///
/// Home screen. Contains just two buttons currently: Video List one and Log Out one
///
struct HomeView: View, Themeable {
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var currentState: UserSessionState
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedTag: Int? = 1

    private var contentView: some View {
        VStack {
            Spacer()
            Image("icon-logo")
                .resizable()
                .scaledToFit()
                .frame(height: 100.0)
            Spacer()
            VideoListButton(title: "Video List",
                            action: $viewModel.actions,
                            runAction: .videoList)
            Spacer()
                .frame(height: 65.0)
            LogOutButton(title: "Log Out",
                         action: $viewModel.actions,
                         runAction: .logOut)
            Spacer()
                .frame(height: 65.0)
        }
        .loadingIndicator(viewModel.isAvatarDownloading)
        .edgesIgnoringSafeArea(.bottom)
    }

    var body: some View {
        if currentState.isConnected == false {
            // The user has not logged in yet: go to the Log In view
            NavigationLink(destination: MainBodyView(),
                           tag: selectedTag!,
                           selection: $selectedTag) {
                EmptyView()
            }
        } else if viewModel.actions == .videoList {
            // go to the next screen automatically if the tag is equal to the selection value
            NavigationLink(destination: VideoListView(),
                           tag: selectedTag!,
                           selection: $selectedTag) {
                EmptyView()
            }
        }
        contentView
            .navigationBar(title: "Live Events")
            .navigationBarItems(leading: UserNameView(),
                                trailing: UserAvatarView())
            .onAppear {
                viewModel.actions = .nothing
            }
    }
}

/// User name View
struct UserNameView: View, Themeable {
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Text(viewModel.userName)
            .foregroundColor(userNameColor)
            .onAppear {
                Task {
                    await viewModel.downloadUserName()
                }
            }
    }
}

/// User's profile avatar image View
struct UserAvatarView: View {
    var body: some View {
        HStack {
            AvatarImageView()
                .padding(.trailing, 0.0)
        }
    }
}

/// Video list button
struct VideoListButton: View, Themeable {
    @Environment(\.colorScheme) var colorScheme

    var title: String
    @Binding var action: HomeViewActions
    let runAction: HomeViewActions

    var body: some View {
        Button(action: {
            action = runAction
        }, label: {
            Text(title)
                .padding()
                .foregroundColor(videoListButtonColor)
        })
        .style(appStyle: .redBorderButton)
        .frame(width: 130.0, height: 20.0)
    }
}

/// Log out button
struct LogOutButton: View, Themeable {
    @Environment(\.colorScheme) var colorScheme

    let title: String
    @Binding var action: HomeViewActions
    let runAction: HomeViewActions

    var body: some View {
        Button(action: {
            action = runAction
        }, label: {
            Text(title)
                .padding()
                .foregroundColor(logOutButtonColor)
        })
        .style(appStyle: .noStyle)
        .frame(width: 130.0, height: 20.0)
    }
}

/// Home view Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(initialState: .init(userSession: nil),
                          reducer: authReducer,
                          environment: NetworkService(with: SignInService()))
        let viewModel = HomeViewModel(store: store)
        HomeView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
            .previewDisplayName("iPhone 12 Pro")
            .environmentObject(viewModel)
    }
}
