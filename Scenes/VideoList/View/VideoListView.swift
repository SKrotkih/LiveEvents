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

    private var contentView: some View {
        VStack {
            Spacer()
                .frame(height: 30.0)
            if viewModel.errorMessage.isEmpty {
                VideoList(viewModel: viewModel)
            } else {
                ErrorMessage()
            }
        }
        .loadingIndicator(viewModel.isDataDownloading)
    }

    var body: some View {
        contentView
            .navigationBar(title: "My video list")
            .navigationBarItems(leading: BackButton(),
                                trailing: NewStreamButton())
            .onAppear {
                viewModel.loadData()
            }
    }
}

/// TODO: As you can see here is used a protocol instead of concrete class like on rest of codebase.
/// We should use protocol anywhere
struct VideoList<ViewModel>: View, Themeable where ViewModel: VideoListViewModelInterface {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        List {
            ForEach(viewModel.sections, id: \.self) { section in
                Section(header: Text(section.sectionName)
                    .font(.title)
                    .foregroundColor(videoListSectionColor)) {
                        ForEach(section.rows, id: \.self) { item in
                            NavigationLink(destination: VideoControllerView(videoId: item.videoId,
                                                                            title: item.title)) {
                                HStack {
                                    Text(item.title)
                                        .foregroundColor(videoListItemColor)
                                    Spacer(minLength: 5.0)
                                    Text("\(item.publishedAt)")
                                        .foregroundColor(videoListItemColor)
                                }
                            }
                        }
                    }
            }
        }
        .listStyle(GroupedListStyle())
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

/// New Stream button. The user presses on the button to go NewStreamView
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
                destination: NewStreamView(),
                tag: 1,
                selection: $action
            ) {
                EmptyView()
            }
        }
    }
}
