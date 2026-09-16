//
//  LogInView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//
import SwiftUI
import SwiftGoogleSignIn

/// Google sign-in screen.
struct LogInView: View {
    @EnvironmentObject var viewModel: LogInViewModel
    @EnvironmentObject var store: AuthReduxStore

    private var isAskingForScopes: Binding<Bool> {
        Binding(
            get: { if case .missingScopes = store.state.error { return true } else { return false } },
            set: { if !$0 { viewModel.dismissError() } }
        )
    }

    var body: some View {
        VStack {
            Spacer()
            Image("icon-logo")
                .resizable()
                .scaledToFit()
                .frame(height: 100.0)
            Spacer()
            if case .message(let text) = store.state.error, !text.isEmpty {
                Text(text)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                Spacer()
                    .frame(height: 30.0)
            }
            SignInButton()   // Google's native button; calls API.logIn()
                .padding()
                .frame(width: 130.0, height: 20.0)
            Spacer()
                .frame(height: 60.0)
        }
        .onAppear {
            viewModel.configurePresenter()
        }
        .alert("YouTube permissions", isPresented: isAskingForScopes) {
            Button("Grant") { viewModel.requestPermissions() }
            Button("Cancel", role: .cancel) { viewModel.dismissError() }
        } message: {
            Text(store.state.error?.message ?? "")
        }
    }
}

#Preview {
    let environment = AppEnvironment()
    LogInView()
        .environmentObject(environment.store)
        .environmentObject(LogInViewModel(store: environment.store))
}
