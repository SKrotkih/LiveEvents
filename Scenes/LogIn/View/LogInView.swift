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
    @State private var selectedTag: Int? = 1

    var body: some View {
        if viewModel.isConnected {
            NavigationLink(destination: MainBodyView(),
                           tag: 1,
                           selection: $selectedTag) {
                EmptyView()
            }
        }
        contentView
        .onAppear {
            viewModel.subscribeOnLogInState()
        }
    }

    private var contentView: some View {
        VStack {
            Spacer()
            Image("icon-logo")
                .resizable()
                .scaledToFit()
                .frame(height: 100.0)
                .padding(30)
            Spacer()
            if viewModel.errorMessage.isEmpty {
                EmptyView()
            } else {
                Text(viewModel.errorMessage)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.red)
                    .padding(30.0)
            }
            SignInButton()   // native google sign in button will be shown here
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
                          environment: NetworkService())
        LogInView(viewModel: LogInViewModel(store: store))
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
            .previewDisplayName("iPhone 12 Pro")
    }
}
