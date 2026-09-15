//
//  YTApiProvider.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 6/26/22.
//

import Foundation
import YTLiveStreaming

/// Hands the YouTube client the access token that SwiftGoogleSignIn put into the Redux store.
/// The library never sees Google Sign-In itself — this is the only bridge.
struct ReduxTokenProvider: TokenProvider, @unchecked Sendable {
    let store: AuthReduxStore

    func accessToken() async throws -> String {
        guard let session = await store.state.userSession,
              let token = session.remoteSession?.accessToken, !token.isEmpty else {
            throw YouTubeLiveError.missingAccessToken
        }
        return token
    }
}

struct YTApiProvider {
    let store: AuthReduxStore

    func getApi() -> YouTubeLiveClient {
        YouTubeLiveClient(tokenProvider: ReduxTokenProvider(store: store))
    }
}
