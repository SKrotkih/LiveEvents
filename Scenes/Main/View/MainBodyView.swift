//
//  MainBodyView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI
import Combine

/// Show sign in view or home view depends on the user  has logged in already
struct MainBodyView: View {
    @EnvironmentObject var currentState: CurrentSessionState
    
    var body: some View {
        NavigationView {
            contentView
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarTitle(Text("Live Events"), displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .statusBar(hidden: true)
        }
    }

    private var contentView: some View {
        VStack {
            VStack {
                if currentState.isConnected {
                    HomeView()
                } else {
                    LogInView()
                }
            }
        }
    }
}
