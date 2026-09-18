import Foundation
import YTLiveStreaming

struct LiveRoute: Hashable {
    let broadcast: LiveBroadcastStreamModel

    static func == (lhs: LiveRoute, rhs: LiveRoute) -> Bool {
        lhs.broadcast.id == rhs.broadcast.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(broadcast.id)
    }
}
