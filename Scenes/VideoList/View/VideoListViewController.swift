//
//  VideoListViewController.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit

// [START viewcontroller_interfaces]
class VideoListViewController: BaseViewController {
    // [END viewcontroller_interfaces]

    @Lateinit var store: AuthReduxStore
    @Lateinit var broadcastsAPI: BroadcastsAPI

    override func viewDidLoad() {
        super.viewDidLoad()

        needNavBarHideShowControl = true
        addBodyView()
    }

    private func addBodyView() {
        let viewModel = VideoListViewModel()
        let dataSource = VideoListFetcher(broadcastsAPI: broadcastsAPI)
        viewModel.dataSource = dataSource
        let bodyView = VideoListView(viewModel: viewModel).environmentObject(store)
        addSwiftUIbodyView(bodyView, to: view)
    }
}
