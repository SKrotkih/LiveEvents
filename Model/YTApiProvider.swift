//
//  YTApiProvider.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 6/26/22.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//

import Foundation
import YTLiveStreaming
import SwiftGoogleSignIn

struct YTApiProvider {

    func getApi() -> YTLiveStreaming {
        let signInModel = SignInModel()
        GoogleOAuth2.sharedInstance.accessToken = signInModel.user?.accessToken
        return YTLiveStreaming()
    }
}
