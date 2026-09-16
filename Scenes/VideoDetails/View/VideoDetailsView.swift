//
//  VideoDetailsView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 23.12.2022.
//
import SwiftUI
import YTLiveStreaming

struct VideoDetailsView: View, Themeable {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var environment: AppEnvironment
    @ObservedObject var viewModel: VideoDetailsViewModel
    @State private var showMore = false

    var body: some View {
        contentView
            .navigationBar(title: viewModel.title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { BackButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: DetailsRoute.update) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Update")
                        }
                        .foregroundColor(videoListPlusButtonColor)
                    }
                }
            }
            .navigationDestination(for: DetailsRoute.self) { route in
                switch route {
                case .player:
                    VideoControllerView(videoId: viewModel.broadcastId, title: viewModel.title)
                case .update:
                    UpdateBroadcastView(viewModel: viewModel)
                }
            }
            .navigationDestination(for: LiveRoute.self) { route in
                LiveStreamView(broadcast: route.broadcast, broadcastsAPI: environment.youtube)
            }
    }

    private var contentView: some View {
        VStack {
            NavigationLink(value: DetailsRoute.player) {
                ZStack {
                    ThumbnailImage(url: viewModel.thumbnailsHigh.0,
                                   width: viewModel.thumbnailsHigh.1,
                                   height: viewModel.thumbnailsHigh.2)
                    Image(systemName: "play.rectangle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                        .frame(width: 60.0, height: 60.0)
                }
            }
            DetailsRow(title: "", value: viewModel.title)
            if viewModel.canGoLive {
                GoLiveButton(broadcast: viewModel.broadcast)
                    .padding(.vertical, 8.0)
            }
            HStack {
                Button(action: { showMore.toggle() }, label: {
                    Text("\(Image(systemName: showMore ? "chevron.up" : "chevron.down")) More details...")
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                })
                .padding(.leading, 20.0)
                Spacer()
            }
            if showMore { moreDetails }
            Spacer()
        }
    }

    private var moreDetails: some View {
        ScrollView {
            VStack {
                DetailsRow(title: "Description", value: viewModel.description)
                DetailsRow(title: "Added to the live broadcast schedule", value: viewModel.publishedAt)
                DetailsRow(title: "Scheduled start", value: viewModel.scheduledStartTime)
                DetailsRow(title: "Scheduled end", value: viewModel.scheduledEndTime)
                DetailsRow(title: "Actually started", value: viewModel.actualStartTime)
                DetailsRow(title: "Actually ended", value: viewModel.actualEndTime)
                DetailsRow(title: "Life cycle status", value: viewModel.lifeCycleStatus ?? "-")
            }
        }
    }

    private enum DetailsRoute: Hashable {
        case player
        case update
    }

    struct DetailsRow: View {
        let title: String
        let value: String?

        var body: some View {
            VStack {
                HStack {
                    Text(title + ":")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.trailing, 5.0)
                    Spacer()
                }
                HStack {
                    Text(value ?? "-")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                    Spacer()
                }
            }
            .padding(.leading, 20.0)
            .padding(.bottom, 5.0)
        }
    }
}

/// Opens the camera screen and streams this broadcast to YouTube (physical device only).
struct GoLiveButton: View {
    let broadcast: LiveBroadcastStreamModel

    var body: some View {
        NavigationLink(value: LiveRoute(broadcast: broadcast)) {
            HStack {
                Image(systemName: "dot.radiowaves.left.and.right")
                Text("Go live").fontWeight(.semibold)
            }
            .padding(.horizontal, 24.0)
            .padding(.vertical, 10.0)
            .foregroundColor(.white)
            .background(Color.red)
            .cornerRadius(10.0)
        }
    }
}
