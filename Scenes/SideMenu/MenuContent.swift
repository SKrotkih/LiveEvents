//
//  MenuContent.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 22.12.2022.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//
import SwiftUI

struct MenuContent: View, Themeable {
    @EnvironmentObject var menuViewModel: MenuViewModel
    @EnvironmentObject var listViewModel: VideoListViewModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var isShowing: Bool

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        self.isShowing = false
                    }
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.bottom, 5.0)
            HStack {
                UserAvatarView()
                    .padding(.leading, 5.0)
                Spacer()
                UserNameView()
                    .padding(.trailing, 5.0)
            }
            Spacer()
                .frame(height: 15.0)
            HStack {
                SortOfListRadioButton()
                Spacer()
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
                             action: $menuViewModel.actions,
                             runAction: .logOut)
                Spacer()
            }
            Spacer()
                .frame(height: 35.0)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(menuBackgroundColor)
        .edgesIgnoringSafeArea(.all)
    }
}

/// User name View
struct UserNameView: View, Themeable {
    @EnvironmentObject var viewModel: MenuViewModel
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

struct SortOfListRadioButton: View {
    @EnvironmentObject var listViewModel: VideoListViewModel
    @State private var selection: Option?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Sort My Videos")
                    .foregroundColor(.white)
                    .font(.system(size: 12))
                    .frame(height: 22.0)
                Spacer()
            }
            RadioButtonGroup(selection: $selection,
                             orientation: .vertical,
                             tags: Option.allCases,
                             button: { isSelected in
                ZStack {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                    if isSelected {
                        Circle()
                            .foregroundColor(.red)
                            .frame(width: 14, height: 14)
                    }
                }
            }, label: { tag in
                Text("\(tag.description)")
                    .foregroundColor(.white)
                    .font(.system(size: 12))
            })
        }
        .padding(20)
        .onChange(of: selection) { selected in
            switch selected {
            case .first:
                listViewModel.selectedListType.send(.byLifeCycleStatus)
            case .second:
                listViewModel.selectedListType.send(.byVideoState)
            case .none:
                break
            }
        }
        .onAppear {
            selection = listViewModel.selectedListType.value == .byLifeCycleStatus ? .first : .second
        }
    }

    enum Option: CaseIterable, CustomStringConvertible {
        case first, second

        var description: String {
            switch self {
            case .first:
                return "By Life Cycle Status"
            case .second:
                return "By Video State"
            }
        }
    }
}
