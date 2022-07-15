//
//  AppRouter.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation

let Router = AppRouter.shared

class AppRouter: NSObject {

    static let shared = AppRouter()

    private let store: AuthStore
    private let signInService: SignInService

    private override init() {
        signInService = SignInService()
        store = Store(initialState: .init(userSession: nil), reducer: authReducer, environment: signInService)
        signInService.store = store
        signInService.configure()
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

    // Home screen
    func openMainScreen() {
        DispatchQueue.performUIUpdate {
            UIStoryboard.main.segueToRootViewController(self.mainScreenDependencies)
        }
    }

    // Video List Screen
    func openVideoListScreen() {
        DispatchQueue.performUIUpdate {
            UIStoryboard.main.sequePushViewController(self.videoListScreenDependencies)
        }
    }

    // Start Live Video
    func openLiveVideoScreen() {
        DispatchQueue.performUIUpdate {
            UIStoryboard.main.segueToModalViewController(self.liveVideoDependencies, optional: nil)
        }
    }

    // Start Live Video
    func openYouTubeVideoPlayer(videoId: String) {
        DispatchQueue.performUIUpdate {
            if #available(iOS 13.0, *) {
                // Use the Video player UI designed with using SwiftUI
                if let window = AppDelegate.shared.window {
                    let viewController = SwiftUiVideoPlayerViewController()
                    self.swiftUiVideoPlayerDependencies(viewController, videoId)
                    window.rootViewController?.present(viewController, animated: false, completion: {})
                }
            } else {
                // Use the Video player UI designed with using UIKit
                UIStoryboard.main.segueToModalViewController(self.videoPlayerDependencies, optional: videoId)
            }
        }
    }

    // New stream
    func showNewStreamScreen() {
        DispatchQueue.performUIUpdate {
            UIStoryboard.main.sequePushViewController(self.newStreamDependencies)
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
        signInService.presentingViewController = viewController
    }

    ///
    /// Inject dependecncies in the VideoListViewController
    ///
    private func videoListScreenDependencies(_ viewController: VideoListViewController) {
        viewController.store = store

        let viewModel = VideoListViewModel()
        let dataSource = VideoListDataSource()
        dataSource.broadcastsAPI = apiProvider.getApi()
        viewModel.dataSource = dataSource

        // Inbound Broadcast
        viewController.output = viewModel
        viewController.input = viewModel
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
        return signInService.openURL(url)
    }
}
