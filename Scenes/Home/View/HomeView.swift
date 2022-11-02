//
//  HomeView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI
import Combine

/// SwiftUI content view for the Home screen
struct HomeView: View {
    @EnvironmentObject var store: AuthReduxStore
    @StateObject var viewModel = HomeViewModel(store: NewRouter.store)
    
    var body: some View {
        contentView
        .navigationBarTitle(Text("Live Events"), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: UserNameView(viewModel.userName),
                            trailing: UserAvatarView(viewModel: viewModel))
    }

    private var contentView: some View {
        VStack {
            Spacer()
            Image("icon-logo")
                .resizable()
                .scaledToFit()
                .frame(height: 100.0)
            Spacer()
            VideoListButton(store: store)
            Spacer()
                .frame(height: 30.0)
            LogOutButton(viewModel: viewModel)
            Spacer()
                .frame(height: 30.0)
        }
        .loadingIndicator(viewModel.isAvatarDownloading)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct UserNameView: View {
    let userName: String

    init(_ userName: String) {
        self.userName = userName
    }

    var body: some View {
        Text(self.userName)
    }
}

struct UserAvatarView<ViewModel>: View where ViewModel: HomeViewModelInterface {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        HStack {
            AvatarImageView(viewModel: viewModel)
                .padding(.trailing, 0.0)
        }
    }
}

struct VideoListButton: View {
    @State private var selectedTag: Int? = 0
    let videoListViewModel: VideoListViewModel

    init(store: AuthReduxStore) {
        videoListViewModel = VideoListViewModel()
        let dataSource = VideoListFetcher(broadcastsAPI: YTApiProvider(store: store).getApi())
        videoListViewModel.dataSource = dataSource
    }

    var body: some View {
        // go to the next screen automatically if the tag is equal to the selection value
        NavigationLink(destination: VideoListView(viewModel: videoListViewModel),
                       tag: 1,
                       selection: $selectedTag) {
            EmptyView()
        }
        Button(action: {
            selectedTag = 1 // go to the Video List screen immediately
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
    }
}

struct LogOutButton<ViewModel>: View where ViewModel: HomeViewModelInterface {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        Button(action: {
            viewModel.logOut()
        }, label: {
            Text("Log Out")
                .padding()
                .frame(width: 130.0)
                .foregroundColor(.white)
        })
        .frame(height: 100.0)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(initialState: .init(userSession: nil),
                          reducer: authReducer,
                          environment: NetworkService())
        HomeView(viewModel: HomeViewModel(store: store))
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
            .previewDisplayName("iPhone 12 Pro")
            .environmentObject(store)
    }
}
