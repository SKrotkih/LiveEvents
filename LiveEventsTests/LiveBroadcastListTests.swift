//
//  LiveBroadcastListTests.swift
//  LiveEventsTests
//
//  Created by Serhii Krotkykh on 05.05.2021.
//  Copyright © 2021 Serhii Krotkykh. All rights reserved.
//

@testable import LiveEvents
import SwiftyJSON
import XCTest
import YTLiveStreaming

class LiveBroadcastListTestCase: XCTestCase {

    // MARK: - Class Setup and Teardown

    override func setUp() {
        super.setUp()
    }

    // MARK: - Live Broadcasts Section

    func testLiveBroadcastList() {
        Task {
            let data = await DecodeData.loadMockData("LiveBroadcastAll.json", as: LiveBroadcastListModel.self)
            switch data {
            case .success(let model):
                print(model)
                XCTAssertEqual(model.items.count, 3)
            case .failure(let error):
                XCTFail(error.message())
            }
        }
    }
}
