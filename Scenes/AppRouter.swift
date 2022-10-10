//
//  AppRouter.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit
import Combine

let Router = AppRouter.shared

class AppRouter: NSObject {

    static let shared = AppRouter()

    private let store: AuthReduxStore
    private let environment: NetworkService

    private override init() {
        environment = NetworkService()
        store = Store(initialState: .init(userSession: nil), reducer: authReducer, environment: environment)
        environment.service.store = store
        environment.service.configure()
    }

    enum StroyboadType: String, Iteratable {
        case main = "Main"
        var filename: String {
            return rawValue.capitalized
        }
    }

    lazy var apiProvider: YTApiProvider = {
        YTApiProvider(store: store)
    }()

    lazy var videoPlayerViewController: SwiftUiVideoPlayerViewController = {
        SwiftUiVideoPlayerViewController()
    }()

    // Home screen
    @MainActor
    func openMainScreen() {
        UIStoryboard.main.segueToRootViewController(self.mainScreenDependencies)
    }

    // Video List Screen
    @MainActor
    func openVideoListScreen() {
        UIStoryboard.main.sequePushViewController(self.videoListScreenDependencies)
    }

    // Start Live Video
    @MainActor
    func openLiveVideoScreen() {
        UIStoryboard.main.segueToModalViewController(self.liveVideoDependencies, optional: nil)
    }

    @MainActor
    func presentModalVideoPlayerView(videoId: String) {
        UIStoryboard.main.segueToModalViewController(self.videoPlayerDependencies, optional: videoId)
    }

    // New stream
    @MainActor
    func showNewStreamScreen() {
        UIStoryboard.main.sequePushViewController(self.newStreamDependencies)
    }

    // Start Live Video
    @MainActor
    func playVideo(with videoId: String) {
        if #available(iOS 13.0, *) {
            presentModalNewVideoPlayerView(videoId: videoId)
        } else {
            presentModalVideoPlayerView(videoId: videoId)
        }
    }

    // Play Video
    @MainActor
    func presentModalNewVideoPlayerView(videoId: String) {
        swiftUiVideoPlayerDependencies(videoPlayerViewController, videoId)
        if let rootViewController = AppDelegate.shared.window?.rootViewController {
            rootViewController.present(self.videoPlayerViewController, animated: false, completion: {})
        }
    }
}

// MARK: - Dependencies Injection

extension AppRouter {
    ///
    /// Inject dependecncies in the MainViewController
    ///
    private func mainScreenDependencies(_ viewController: MainViewController) {
        viewController.store = store
        environment.service.presentingViewController = viewController
    }

    ///
    /// Inject dependecncies in the VideoListViewController
    ///
    private func videoListScreenDependencies(_ viewController: VideoListViewController) {
        viewController.store = store
        viewController.broadcastsAPI = apiProvider.getApi()
    }

    ///
    /// Inject dependecncies in the LFLiveViewController
    ///
    private func liveVideoDependencies(_ viewController: LFLiveViewController, _ optional: Any?) {
        let viewModel = LiveStreamingViewModel()
        viewModel.broadcastsAPI = apiProvider.getApi()
        viewController.viewModel = viewModel
    }
    ///
    /// Inject dependecncies in the LFLiveViewController
    ///
    private func newStreamDependencies(_ viewController: NewStreamViewController) {
        let viewModel = NewStreamViewModel()
        viewModel.broadcastsAPI = apiProvider.getApi()
        viewController.viewModel = viewModel
    }
    /// UIKit:
    /// Inject dependecncies in to the VideoPlayerViewController
    ///
    private func videoPlayerDependencies(_ viewController: VideoPlayerViewController, _ optional: Any?) {
        VideoPlayerConfigurator.configure(viewController, optional)
    }
    /// SwiftUI:
    /// Inject dependecncies in to the (SwiftUI version of the VideoPlayerViewController) SwiftUiVideoPlayerViewController
    ///
    private func swiftUiVideoPlayerDependencies(_ viewController: SwiftUiVideoPlayerViewController, _ optional: Any?) {
        SwiftUIVideoPlayerConfigurator.configure(viewController, optional)
    }
}

extension AppRouter {
    func closeModal(viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIApplicationDelegate protocol.

extension AppRouter: UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        openMainScreen()
        return true
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return environment.service.openURL(url)
    }
}
