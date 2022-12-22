//
//  SideMenuContent.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 22.12.2022.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//
import SwiftUI

struct SideMenuContent: View, Themeable {
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var showSideMenu: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        self.showSideMenu = false
                    }
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.bottom, 15.0)
            HStack {
                UserAvatarView()
                    .padding(.leading, 5.0)
                Spacer()
                UserNameView()
                    .padding(.trailing, 5.0)
            }
            Spacer()
            HStack {
                Spacer()
                Image("icon-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100.0)
                Spacer()
            }
            Spacer()
                .frame(height: 15.0)
            HStack {
                Spacer()
                LogOutButton(title: "Log Out",
                             action: $viewModel.actions,
                             runAction: .logOut)
                Spacer()
            }
            Spacer()
                .frame(height: 35.0)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray)
        .edgesIgnoringSafeArea(.all)
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
