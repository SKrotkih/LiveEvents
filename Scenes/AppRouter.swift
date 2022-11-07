//
//  AppRouter.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit

import SwiftUI
import Combine

let Router = AppRouter.shared

class AppRouter: NSObject {

    static let shared = AppRouter()

    let store: AuthReduxStore
    let environment: NetworkService
    
    lazy var apiProvider: YTApiProvider = {
        YTApiProvider(store: store)
    }()

    enum StroyboadType: String, Iteratable {
        case main = "Main"
        var filename: String {
            return rawValue.capitalized
        }
    }

    private override init() {
        environment = NetworkService()
        store = Store(initialState: .init(userSession: nil), reducer: authReducer, environment: environment)
        environment.service.store = store
    }

    func environmentConfigure() {
        environment.service.configure()
    }
    
    // Start Live Video
    @MainActor
    func playVideo(with videoId: String) { }
    
    // Start Live Video
    @MainActor
    func openLiveVideoScreen() {
        UIStoryboard.main.segueToModalViewController(self.liveVideoDependencies, optional: nil)
    }
}

// MARK: - Dependencies Injection

extension AppRouter {
    ///
    /// Inject dependecncies in the LFLiveViewController
    ///
    private func liveVideoDependencies(_ viewController: LFLiveViewController, _ optional: Any?) {
        let viewModel = LiveStreamingViewModel()
        viewModel.broadcastsAPI = apiProvider.getApi()
        viewController.viewModel = viewModel
    }
}

// MARK: - UIApplicationDelegate protocol.

extension AppRouter: UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return environment.service.openURL(url)
    }
}

extension AppRouter {
    func closeModal(viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
