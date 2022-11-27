//
//  YTApiProvider.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 6/26/22.
//

import Foundation
import YTLiveStreaming

struct YTApiProvider {
    let store: AuthReduxStore

    func getApi() -> YTLiveStreaming {
        Task {
            if let userSession = await store.state.userSession,
               let remoteSession = userSession.remoteSession {
                GoogleOAuth2.sharedInstance.accessToken = remoteSession.accessToken
            }
        }
        return YTLiveStreaming()
    }
}
