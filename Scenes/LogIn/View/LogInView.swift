//
//  LogInView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import SwiftUI
import SwiftGoogleSignIn

/// SwiftUI content view for the Google Sign In
struct LogInView<ViewModel>: View where ViewModel: LogInViewModelInterface {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            Spacer()
            Image("icon-logo")
                .resizable()
                .scaledToFit()
                .frame(height: 100.0)
                .padding(30)
            Spacer()
            Text(viewModel.errorMessage)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .padding(25.0)
                .foregroundColor(.red)
            VStack {
                SignInButton()
                    .padding()
                    .frame(width: 130.0)
            }
            .frame(height: 20.0)
        }
        .padding(.top, 30.0)
        .padding(.bottom, 30.0)
        .onAppear {
            viewModel.subscribeOnLogInState()
        }
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(initialState: .init(userSession: nil),
                          reducer: authReducer,
                          environment: NetworkService())
        LogInView(viewModel: LogInViewModel(store: store))
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
            .previewDisplayName("iPhone 12 Pro")
    }
}
