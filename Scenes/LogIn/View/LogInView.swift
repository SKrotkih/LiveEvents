//
//  LogInView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI
import SwiftGoogleSignIn

///
/// Google Sign In content view
///
struct LogInView: View {
    @EnvironmentObject var viewModel: LogInViewModel
    @EnvironmentObject var currentState: UserSessionState

    var body: some View {
        contentView
        .onAppear {
            // Set up the window root view controller as the `GIDSignIn` presenting view controller.
            viewModel.configure(with: AppDelegate.shared.window?.rootViewController ?? UIHostingController(rootView: self))
        }
    }

    private var contentView: some View {
        VStack {
            Spacer()
            Image("icon-logo")
                .resizable()
                .scaledToFit()
                .frame(height: 100.0)
            Spacer()
            if let errorMessage = currentState.errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.red)
                Spacer()
                    .frame(height: 30.0)
            } else {
                EmptyView()
            }
            SignInButton()   // native Google Sign in button will be shown here
                .padding()
                .frame(width: 130.0, height: 20.0)
            Spacer()
                .frame(height: 60.0)
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(initialState: .init(userSession: nil),
                          reducer: authReducer,
                          environment: NetworkService(with: SignInService()))
        let viewModel = LogInViewModel(store: store)
        LogInView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
            .previewDisplayName("iPhone 12 Pro")
            .environmentObject(viewModel)
    }
}
