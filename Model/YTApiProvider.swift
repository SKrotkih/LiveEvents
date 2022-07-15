//
//  YTApiProvider.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 6/26/22.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//

import Foundation
import YTLiveStreaming

struct YTApiProvider {
    let store: AuthStore

    func getApi() -> YTLiveStreaming {
        GoogleOAuth2.sharedInstance.accessToken = store.state.userSession?.remoteSession.accessToken
        return YTLiveStreaming()
    }
}
