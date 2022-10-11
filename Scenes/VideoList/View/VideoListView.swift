//
//  VideoListView.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 10/9/22.
//

import SwiftUI
import Combine

protocol VideoListViewModelInterface: ObservableObject {
    func loadData()
    var sections: [VideoListSection] { get set }
    var errorMessage: String { get set }
    var isDataDownloading: Bool { get set}

    func didCloseViewAction()
    func didUserLogOutAction()
    func createBroadcast()
    func didLaunchStreamAction(indexPath: IndexPath, viewController: UIViewController)
}

struct VideoListView<ViewModel>: View where ViewModel: VideoListViewModelInterface {
    @EnvironmentObject var store: AuthReduxStore
    @ObservedObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            if viewModel.errorMessage.isEmpty {
                VideoList(viewModel: viewModel)
            } else {
                ErrorMessage(viewModel: viewModel)
            }
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
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            ForEach(viewModel.sections, id: \.self) { section in
                Section(header: Text(section.sectionName)
                    .font(.title)
                    .foregroundColor(.white)) {
                        ForEach(section.rows, id: \.self) { item in
                            NavigationLink(destination: VideoPlayerScene(item: item)) {
                                HStack {
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
        .navigationBarTitle(Text("My video list"), displayMode: .inline)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(
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
        )
    }
}

struct ErrorMessage<ViewModel>: View where ViewModel: VideoListViewModelInterface {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text(viewModel.errorMessage)
                .foregroundColor(.red)
        }
        .navigationBarTitle(Text("My video list"), displayMode: .inline)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(
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
        )
    }
}

struct VideoPlayerScene: View {
    @Environment(\.presentationMode) var presentationMode

    let item: VideoListRow
    init(item: VideoListRow) {
        self.item = item
    }

    var body: some View {
        VStack {
            Text(item.title)
                .foregroundColor(.red)
        }
        .navigationBarTitle(Text(item.title), displayMode: .inline)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(
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
        )
    }
}
