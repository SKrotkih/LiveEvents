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
    @EnvironmentObject var store: AuthStore
    var body: some View {
        VStack {
            Spacer()
            Image("icon-logo")
                .resizable()
                .scaledToFit()
            Spacer()
            Text(store.state.logInErrorMessage ?? "")
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .padding(25.0)
                .foregroundColor(.red)
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
