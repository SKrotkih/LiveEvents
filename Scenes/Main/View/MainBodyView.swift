//
//  MainBodyView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//
import SwiftUI
import Combine

/// Video list (Home screen) or the log in screen dispatcher
/// Depends on the current connection state
struct MainBodyView: View {
    @EnvironmentObject var currentState: UserSessionState

    var body: some View {
        NavigationView {
            if currentState.isConnected {
                VideoListView()
            } else {
                LogInView()
            }
        }
    }
}
