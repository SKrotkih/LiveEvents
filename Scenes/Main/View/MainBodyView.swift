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
    let homeBodyViewModel = HomeBodyViewModel()

    var body: some View {
        VStack {
            if store.state.notSignedIn {
                SignInBodyView()
            } else {
                HomeBodyView()
                    .environmentObject(homeBodyViewModel)
            }
        }
    }
}
