@testable import LiveEvents
import XCTest
import YTLiveStreaming

class LiveBroadcastListTestCase: XCTestCase {

    // MARK: - Class Setup and Teardown

    override func setUp() {
        super.setUp()
    }

    // MARK: - Live Broadcasts Section

    func testLiveBroadcastList() async {
        let data = await DecodeData.loadMockData("LiveBroadcastAll.json", as: LiveBroadcastListModel.self)
        switch data {
        case .success(let model):
            XCTAssertEqual(model.items.count, 4)
            XCTAssertTrue(model.items.allSatisfy { $0.lifeCycleStatus != .unknown })
        case .failure(let error):
            XCTFail(error.message())
        }
    }
}
