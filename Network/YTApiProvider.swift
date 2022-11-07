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
            if let userSession = await store.state.userSession {
                GoogleOAuth2.sharedInstance.accessToken = userSession.remoteSession.accessToken
            }
        }
        return YTLiveStreaming()
    }
}
