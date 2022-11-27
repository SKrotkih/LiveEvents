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

///
/// Attempt of the app router implementation
///
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
    @MainActor
    func getMainContentView() -> some View {
        ///
        /// For the  app views environment configuration
        ///
        let store = Router.store
        let broadcastsAPI = YTApiProvider(store: store).getApi()
        let homeViewModel = HomeViewModel(store: store)
        let logInViewModel = LogInViewModel(store: store)
        let dataSource = VideoListFetcher(broadcastsAPI: broadcastsAPI)
        let videoListViewModel = VideoListViewModel(store: store, dataSource: dataSource)
        let newStreamViewModel = NewStreamViewModel()
        newStreamViewModel.broadcastsAPI = broadcastsAPI
        let currentState = UserSessionState()
        Router.environmentConfigure()

        let contentView = MainBodyView()
            .environmentObject(store)
            .environmentObject(homeViewModel)
            .environmentObject(logInViewModel)
            .environmentObject(videoListViewModel)
            .environmentObject(newStreamViewModel)
            .environmentObject(currentState)

        return contentView
    }
}

extension AppRouter {
    ///
    /// Inject dependecncies in the LFLiveViewController (old fashion)
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
