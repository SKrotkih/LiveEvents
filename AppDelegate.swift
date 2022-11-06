//
//  AppDelegate.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit
import SwiftUI
import Combine

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy private var observers: [UIApplicationDelegate]? = [
        WindowCustomizer(),
        // Should be last on the list
        Router
    ]

    static var shared: AppDelegate {
        guard let `self` = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return self
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        observers?.forEach {
            _ = $0.application?(application, didFinishLaunchingWithOptions: launchOptions)
        }
        return true
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        observers?.forEach {
            _ = $0.application?(application, open: url, options: options)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
      // Called when a new scene session is being created.
      // Use this method to select a configuration to create the new scene with.
      return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
      // Called when the user discards a scene session.
      // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
      // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // configure environment (DI)
        let store = NewRouter.store
        let broadcastsAPI = YTApiProvider(store: store).getApi()
        let homeViewModel = HomeViewModel(store: store)
        let logInViewModel = LogInViewModel(store: store)
        let dataSource = VideoListFetcher(broadcastsAPI: broadcastsAPI)
        let videoListViewModel = VideoListViewModel(store: store, dataSource: dataSource)
        let newStreamViewModel = NewStreamViewModel()
        newStreamViewModel.broadcastsAPI = broadcastsAPI

        let contentView = MainBodyView()
            .environmentObject(store)
            .environmentObject(homeViewModel)
            .environmentObject(logInViewModel)
            .environmentObject(videoListViewModel)
            .environmentObject(newStreamViewModel)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            AppDelegate.shared.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}
