//
//  MainBodyView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI
import Combine

/// Show sign in view or home view depends on the user  has logged or not
struct MainBodyView: View {
    @EnvironmentObject var currentState: CurrentSessionState
    
    var body: some View {
        NavigationView {
            contentView
                .navigationBar(title: "Live Events")
        }
    }

    private var contentView: some View {
        VStack {
            if currentState.isConnected {
                HomeView()
            } else {
                LogInView()
            }
        }
    }
}
