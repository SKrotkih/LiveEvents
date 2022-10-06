//
//  MainViewController.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit

// [START viewcontroller_interfaces]
class MainViewController: BaseViewController {
    // [END viewcontroller_interfaces]

    @Lateinit var store: AuthReduxStore

    override func viewDidLoad() {
        super.viewDidLoad()

        needNavBarHideShowControl = true
        addBodyView()
    }

    private func addBodyView() {
        let bodyView = MainBodyView().environmentObject(store)
        addSwiftUIbodyView(bodyView, to: view)
    }
}
