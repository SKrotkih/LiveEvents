//
//  VideoListView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI
import Combine

protocol VideoListViewModelDataSource: ObservableObject {
    func loadData()
    var sections: [VideoListSection] { get set }
    var errorMessage: String { get set }
    var isDataDownloading: Bool { get set}
}

protocol VideoListViewModelActions {
    func didCloseViewAction()
    func didUserLogOutAction()
    func createBroadcast()
}

typealias VideoListViewModelInterface = VideoListViewModelDataSource & VideoListViewModelActions

struct VideoListView<ViewModel>: View where ViewModel: VideoListViewModelInterface {
    @EnvironmentObject var store: AuthReduxStore
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.errorMessage.isEmpty {
                    VideoList(viewModel: viewModel)
                } else {
                    ErrorMessage(viewModel: viewModel)
                }
            }
            .navigationBarTitle(Text("My video list"), displayMode: .inline)
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: BackButton())
        }
        .onAppear {
            viewModel.loadData()
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
