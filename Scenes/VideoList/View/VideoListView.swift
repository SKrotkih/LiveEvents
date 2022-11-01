//
//  VideoListView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI
import Combine

struct VideoListView<ViewModel>: View where ViewModel: VideoListViewModelInterface {
    @EnvironmentObject var store: AuthReduxStore
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        contentView
        .navigationBarTitle(Text("My video list"), displayMode: .inline)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton(),
                            trailing: NewStreamButton(store: store))
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
                ErrorMessage(viewModel: viewModel)
            }
        }
        .loadingIndicator(viewModel.isDataDownloading)
    }
}

struct VideoList<ViewModel>: View where ViewModel: VideoListViewModelInterface {
    @EnvironmentObject var store: AuthReduxStore
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

struct ErrorMessage<ViewModel>: View where ViewModel: VideoListViewModelInterface {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            Text(viewModel.errorMessage)
                .foregroundColor(.red)
        }
    }
}

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Button(
            action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                HStack {
                    Image(systemName: "arrow.left.circle")
                        .foregroundColor(.white)
                    Text("Back")
                        .foregroundColor(.white)
                }
            })
    }
}

struct NewStreamButton: View {
    @State private var action: Int? = 0
    let viewModel: NewStreamViewModel

    init(store: AuthReduxStore) {
        viewModel = NewStreamViewModel()
        viewModel.broadcastsAPI = YTApiProvider(store: store).getApi()
    }

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
                destination: NewStreamView(viewModel: viewModel),
                tag: 1,
                selection: $action
            ) {
                EmptyView()
            }
        }
    }
}
