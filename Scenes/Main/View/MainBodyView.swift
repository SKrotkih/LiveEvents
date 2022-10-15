//
//  MainBodyView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI

/// Show sign in view or home view depends on the user  has logged in already
struct MainBodyView: View {
    @EnvironmentObject var store: AuthReduxStore

    var body: some View {
        NavigationView {
            VStack {
                if store.state.isConnected {
                    HomeView(viewModel: HomeViewModel(store: store))
                } else {
                    LogInView(viewModel: LogInViewModel(store: store))
                }
            }
            .navigationBarTitle(Text("Live Events"), displayMode: .inline)
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
        }
    }
}
