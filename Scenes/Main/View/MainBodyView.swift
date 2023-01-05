//
//  MainBodyView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//
import SwiftUI
import Combine

///
/// Switching Sign in view or home view depends on either the user  has logged or not
///
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
