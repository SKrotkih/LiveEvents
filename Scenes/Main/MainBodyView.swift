//
//  MainBodyView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI

/// Show sign in view or home view depends on the user  has logged in already
struct MainBodyView: View {
    @EnvironmentObject var viewModel: GoogleSignInViewModel

    var body: some View {
        VStack {
            if viewModel.user == nil {
                SignInBodyView()
            } else {
                HomeBodyView()
            }
        }
    }
}

struct MainBodyView_Previews: PreviewProvider {
    static var previews: some View {
        MainBodyView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
            .previewDisplayName("iPhone 12 Pro")
    }
}
