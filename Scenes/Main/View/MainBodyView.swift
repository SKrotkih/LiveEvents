//
//  MainBodyView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI

/// Show sign in view or home view depends on the user  has logged in already
struct MainBodyView: View {
    @EnvironmentObject var store: AuthStore

    var body: some View {
        VStack {
            if store.state.isConnected {
                HomeView(viewModel: HomeViewModel())
            } else {
                LogInView(viewModel: LogInViewModel(store: store))
            }
        }
    }
}
