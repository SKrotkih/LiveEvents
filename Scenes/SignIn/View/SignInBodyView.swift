//
//  SignInBodyView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI
import SwiftGoogleSignIn

/// SwiftUI content view for the Google Sign In
struct SignInBodyView: View {

    @EnvironmentObject var viewModel: GoogleSignInViewModel

    var body: some View {
        VStack {
            Spacer()
            Image("icon-logo")
                .resizable()
                .scaledToFit()
            Spacer()
            SignInButton()
            .padding()
            .frame(width: 100.0)
            Spacer()
        }
        .padding(.top, 80.0)
        .padding(.bottom, 80.0)
    }
}

struct SignInBodyView_Previews: PreviewProvider {
    static var previews: some View {
        SignInBodyView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
            .previewDisplayName("iPhone 12 Pro")
    }
}
