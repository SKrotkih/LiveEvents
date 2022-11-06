//
//  VideoListView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI
import Combine

struct VideoListView: View {
    @EnvironmentObject var store: AuthReduxStore
    @EnvironmentObject var viewModel: VideoListViewModel

    var body: some View {
        contentView
        .navigationBarTitle(Text("My video list"), displayMode: .inline)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton(),
                            trailing: NewStreamButton())
        .onAppear {
            viewModel.loadData()
        }
    }

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
}

// TODO: it's a good idea to use like this (protocol instead of class anywhere):
struct VideoList<ViewModel>: View where ViewModel: VideoListViewModelInterface {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        List {
            ForEach(viewModel.sections, id: \.self) { section in
                Section(header: Text(section.sectionName)
                    .font(.title)
                    .foregroundColor(.white)) {
                        ForEach(section.rows, id: \.self) { item in
                            NavigationLink(destination: VideoControllerView(videoId: item.videoId,
                                                                            title: item.title)) {
                                HStack {
                                    // thumbnailsImageView: UIImageView!
                                    Text(item.title)
                                        .foregroundColor(.green)
                                    Spacer(minLength: 5.0)
                                    Text("\(item.publishedAt)")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct ErrorMessage: View {
    @EnvironmentObject var viewModel: VideoListViewModel

    var body: some View {
        VStack {
            Text(viewModel.errorMessage)
                .foregroundColor(.red)
        }
    }
}

struct NewStreamButton: View {
    @State private var action: Int? = 0

    var body: some View {
        HStack {
            Button(action: {
                action = 1
            }, label: {
                HStack {
                    Image(systemName: "plus.app")
                        .foregroundColor(.white)
                    Text("Add")
                        .foregroundColor(.white)
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
