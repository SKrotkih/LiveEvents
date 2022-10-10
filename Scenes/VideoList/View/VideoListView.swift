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

    var body: some View {
        VStack {
            VideoList(sections: viewModel.sections)
            ErrorMessage(text: viewModel.errorMessage)
        }
        .padding(.top, 30.0)
        .padding(.bottom, 30.0)
        .onAppear {
            viewModel.loadData()
        }
    }
}

struct VideoList: View {
    let sections: [VideoListSection]
    init(sections: [VideoListSection]) {
        self.sections = sections
    }

    var body: some View {
        List {
            ForEach(sections, id: \.self) { section in
                Text(section.sectionName)
                    .foregroundColor(.white)
                ForEach(section.rows, id: \.self) { item in
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
