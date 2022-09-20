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
                    .foregroundColor(.gray)
                    .lineLimit(0)
                    .padding(.leading, 30.0)
                Spacer()
                AvatarImageView(viewModel: viewModel)
                    .padding(.trailing, 30.0)
            }
            .frame(height: 30.0)
            Spacer()
            Image("icon-logo")
                .resizable()
                .scaledToFit()
                .frame(height: 100.0)
                .padding(30)
            Spacer()
            Button(action: {
                openVideoListScreen()
            }, label: {
                Text("Video List")
                    .padding()
                    .frame(width: 130.0)
                    .foregroundColor(.red)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.red, lineWidth: 2)
                    )
            })
            .shadow(color: .white, radius: 10, y: 5)
            .frame(height: 20.0)
            Button(action: {
                logOut()
            }, label: {
                Text("Log Out")
                    .padding()
                    .frame(width: 130.0)
                    .foregroundColor(.white)
            })
            .frame(height: 100.0)
        }
        .padding(.top, 30.0)
        .padding(.bottom, 30.0)
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
