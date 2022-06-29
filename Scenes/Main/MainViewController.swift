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

    @Lateinit var signInViewModel: GoogleSignInViewModel

    override func viewDidLoad() {
        super.viewDidLoad()

        needNavBarHideShowControl = true
        addBodyView()
    }

    private func addBodyView() {
        let bodyView = MainBodyView().environmentObject(signInViewModel)
        addSwiftUIbodyView(bodyView, to: view)
    }
}
