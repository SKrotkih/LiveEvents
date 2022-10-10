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
            .navigationBarTitle(Text("My video list").font(.title), displayMode: .inline)
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                                    Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "arrow.left.circle")
                    Text("Back")
                        .foregroundColor(.white)
                }
            })
            //                ErrorMessage(text: viewModel.errorMessage)
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

struct ErrorMessage: View {
    let text: String
    init(text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .foregroundColor(.red)
    }
}

struct VideoPlayerScene: View {
    let item: VideoListRow
    init(item: VideoListRow) {
        self.item = item
    }

    var body: some View {
        Text(item.title)
            .foregroundColor(.red)
    }
}
