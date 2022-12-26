//
//  VideoListView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI
import Combine

/// Three sectioned video list View
/// uses from the VideoListViewModel data and watches for downloading process
struct VideoListView: View {
    @EnvironmentObject var store: AuthReduxStore
    @EnvironmentObject var viewModel: VideoListViewModel
    @State private var isSideMenuShowing = false

    var body: some View {
        contentView
            .navigationBar(title: "My live video")
            .navigationBarItems(leading: SideMenuButton(isSideMenuShown: $isSideMenuShowing),
                                trailing: NewStreamButton())
            .sideMenu(isShowing: $isSideMenuShowing) {
                MenuContent(isShowing: $isSideMenuShowing)
            }
    }

    private var contentView: some View {
        VStack {
            if viewModel.errorMessage.isEmpty {
                VideoList(viewModel: viewModel)
            } else {
                ErrorMessage()
            }
        }
        .loadingIndicator(viewModel.isDataDownloading)
    }
}

/// TODO: As you can see here is used a protocol instead of concrete class like on rest of codebase.
/// We should use protocol anywhere
struct VideoList<ViewModel>: View, Themeable where ViewModel: VideoListViewModelInterface {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        List {
            ForEach(viewModel.sections, id: \.self.id) { section in
                Section(header: Text(section.sectionName)
                    .font(.system(size: 16))
                    .foregroundColor(videoListSectionColor)) {
                        ForEach(section.rows, id: \.self.id) { item in
                            let detailsViewModel = VideoDetailsViewModel(videoDetails: item.model)
                            NavigationLink(destination: VideoDetailsView(viewModel: detailsViewModel)) {
                                ListRow(item: item,
                                        listType: viewModel.selectedListType.value)
                            }
                        }
                    }
            }
        }
        .listStyle(GroupedListStyle())
    }
    
    struct ListRow: View, Themeable {
        @Environment(\.colorScheme) var colorScheme
        let item: VideoListRow
        let listType: ListByType
        
        var body: some View {
            if listType == .byLifeCycleStatus {
                rowLifeCycleStatusItem(item)
                    .padding(.top, 4.0)
                    .padding(.bottom, 4.0)
            } else if listType == .byVideoState {
                rowVideoStateItem(item)
                    .padding(.top, 4.0)
                    .padding(.bottom, 4.0)
            } else {
                EmptyView()
            }
        }
        
        func rowVideoStateItem(_ item: VideoListRow) -> some View {
            HStack(alignment: .center) {
                ThumbnailImage(url: item.model.snippet.thumbnails.def.url,
                               width: 40,
                               height: 40)
                Spacer(minLength: 5.0)
                VStack {
                    HStack {
                        Text(item.model.snippet.title)
                            .foregroundColor(videoListItemColor)
                            .frame(alignment: .top)
                        Spacer()
                    }
                    HStack {
                        Text(item.model.snippet.description)
                            .foregroundColor(videoListItemDateColor)
                            .frame(alignment: .bottom)
                            .font(.system(size: 12))
                        Spacer()
                    }
                }
                Spacer(minLength: 5.0)
                Text("\(item.model.snippet.publishedAt.fullDateFormat)")
                    .foregroundColor(videoListItemDateColor)
                    .font(.system(size: 12))
                    .frame(width: 70.0)
                Spacer()
            }
            .font(.system(size: 14))
        }
        
        func rowLifeCycleStatusItem(_ item: VideoListRow) -> some View {
            HStack(alignment: .center) {
                Spacer(minLength: 5.0)
                ThumbnailImage(url: item.model.snippet.thumbnails.def.url,
                               width: 40,
                               height: 40)
                VStack {
                    HStack {
                        Text(item.model.snippet.title)
                            .foregroundColor(videoListItemColor)
                            .frame(alignment: .top)
                        Spacer()
                    }
                    HStack {
                        Text(item.model.snippet.description)
                            .foregroundColor(videoListItemDateColor)
                            .frame(alignment: .bottom)
                            .font(.system(size: 12))
                        Spacer()
                    }
                }
                Spacer(minLength: 5.0)
                Text("\(item.model.snippet.publishedAt.fullDateFormat)")
                    .foregroundColor(videoListItemDateColor)
                    .font(.system(size: 12))
                    .frame(width: 70.0)
                Spacer()
            }
            .font(.system(size: 14))
        }
    }
}

/// Show error message got while downloading remote data process
struct ErrorMessage: View {
    @EnvironmentObject var viewModel: VideoListViewModel

    var body: some View {
        VStack {
            Text(viewModel.errorMessage)
                .foregroundColor(.red)
        }
    }
}

/// New Stream button. The user presses on the button to go NewBroadcastView
struct NewStreamButton: View, Themeable {
    @State private var action: Int? = 0
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            Button(action: {
                action = 1
            }, label: {
                HStack {
                    Image(systemName: "plus.app")
                        .foregroundColor(videoListPlusButtonColor)
                    Text("Add")
                        .foregroundColor(videoListPlusButtonColor)
                }
            })
            NavigationLink(
                destination: NewBroadcastView(),
                tag: 1,
                selection: $action
            ) {
                EmptyView()
            }
        }
    }
}

/// Video List View Preview
struct VideoListView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(initialState: .init(userSession: nil),
                          reducer: authReducer,
                          environment: NetworkService(with: SignInService()))
        let broadcastsAPI = YTApiProvider(store: store).getApi()
        let dataSource = VideoListFetcher(broadcastsAPI: broadcastsAPI)
        let videoListViewModel = VideoListViewModel(store: store, dataSource: dataSource)
        let menuViewModel = MenuViewModel(store: store)

        VideoListView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
            .previewDisplayName("iPhone 12 Pro")
            .environmentObject(menuViewModel)
            .environmentObject(videoListViewModel)
    }
}

