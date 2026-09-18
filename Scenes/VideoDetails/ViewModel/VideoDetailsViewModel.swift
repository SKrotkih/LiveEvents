import Foundation
import YTLiveStreaming

@MainActor
final class VideoDetailsViewModel: ObservableObject {
    private let model: LiveBroadcastStreamModel

    var broadcastModel: BroadcastModel { BroadcastModel(model: model) }
    var broadcast: LiveBroadcastStreamModel { model }

    /// A broadcast can be taken live from the phone while it is scheduled or already in testing.
    var canGoLive: Bool {
        switch model.lifeCycleStatus {
        case .created, .ready, .testStarting, .testing, .liveStarting, .live:
            return model.contentDetails?.boundStreamId != nil
        default:
            return false
        }
    }

    init(videoDetails: LiveBroadcastStreamModel) {
        self.model = videoDetails
    }

    var title: String { model.snippet.title }
    var broadcastId: String { model.id }
    var lifeCycleStatus: String? { model.status?.lifeCycleStatus.rawValue }
    var channelId: String { model.snippet.channelId }
    var description: String { model.snippet.description }
    var publishedAt: String { model.snippet.publishedAt.fullDateFormat }
    var scheduledStartTime: String? { model.snippet.scheduledStartTime?.fullDateFormat }
    var scheduledEndTime: String? { model.snippet.scheduledEndTime?.fullDateFormat }
    var actualStartTime: String? { model.snippet.actualStartTime?.fullDateFormat }
    var actualEndTime: String? { model.snippet.actualEndTime?.fullDateFormat }
    var thumbnailsHigh: (String?, width: CGFloat, height: CGFloat) {
        let thumbnail = model.snippet.thumbnails?.high
        return (thumbnail?.url, CGFloat(thumbnail?.width ?? 480), CGFloat(thumbnail?.height ?? 360))
    }
}
