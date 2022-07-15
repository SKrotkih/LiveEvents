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
            if store.state.notSignedIn {
                SignInBodyView()
            } else {
                HomeBodyView()
            }
        }
    }
}

struct MainBodyView_Previews: PreviewProvider {
    static var previews: some View {
        let device = "iPhone 12 Pro"
        MainBodyView()
            .previewDevice(PreviewDevice(rawValue: device))
            .previewDisplayName(device)
    }
}
