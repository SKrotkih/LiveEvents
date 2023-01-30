//
//  VideoDetailsView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 23.12.2022.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//
import SwiftUI

struct VideoDetailsView: View, Themeable {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: VideoDetailsViewModel
    @State private var isShowingVideoPlayer = false
    @State private var isShowingUpdate = false
    @State private var isShowninhMore = false

    var body: some View {
        NavigationLink(destination: VideoControllerView(videoId: viewModel.broadcastId,
                                                        title: viewModel.title),
                       isActive: $isShowingVideoPlayer) { EmptyView() }
        NavigationLink(destination: UpdateBroadcastView(viewModel: viewModel),
                       isActive: $isShowingUpdate) { EmptyView() }
        Spacer()
            .frame(height: 55.0)
        contentView
            .navigationBar(title: viewModel.title)
            .navigationBarItems(leading: BackButton(),
                                trailing: UpdateBroadcastButton(viewModel: viewModel,
                                                                action: $viewModel.actions,
                                                                runAction: .update))
            .onChange(of: viewModel.actions) { newValue in
                isShowingVideoPlayer = newValue == .playVideo
                isShowingUpdate = newValue == .update
            }
            .onAppear {
                isShowingVideoPlayer = false
                isShowingUpdate = false
            }
    }

    private var contentView: some View {
        VStack {
            Group {
                ZStack {
                    PlayVideoButton(viewModel: viewModel,
                                    action: $viewModel.actions,
                                    runAction: .playVideo)
                    Image(systemName: "play.rectangle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                        .frame(width: 60.0, height: 60.0)
                }
            }
            DetailsRow(title: "", value: viewModel.title)
            HStack {
                Button(action: {
                    isShowninhMore.toggle()
                }, label: {
                    Text("\(Image(systemName: isShowninhMore ? "chevron.up" : "chevron.down")) More detals...")
                        .foregroundColor(.red)
                        .font(.system(size: 14))
                })
                .padding(.leading, 20.0)
                Spacer()
            }
            if isShowninhMore {
                moreDetails
            } else {
                Spacer()
            }
            Spacer()
                .frame(height: 60.0)
        }
    }

    private var moreDetails: some View {
        ScrollView {
            VStack {
                DetailsRow(title: "Description", value: viewModel.description)
                DetailsRow(title: "The time that the broadcast was added to YouTube's live broadcast schedule", value: viewModel.publishedAt)
                DetailsRow(title: "The date and time that the broadcast is scheduled to start", value: viewModel.scheduledStartTime)
                DetailsRow(title: "The date and time that the broadcast is scheduled to end", value: viewModel.scheduledEndTime)
                DetailsRow(title: "The date and time that the broadcast actually started", value: viewModel.actualStartTime)
                DetailsRow(title: "The date and time that the broadcast actually ended", value: viewModel.actualEndTime)
                DetailsRow(title: "Life cycle video status", value: viewModel.lifeCycleStatus ?? "-")
            }
        }
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

/// Play Video Button
struct PlayVideoButton: View, Themeable {
    @Environment(\.colorScheme) var colorScheme
    let viewModel: VideoDetailsViewModel
    @Binding var action: VideoDetailsActions
    let runAction: VideoDetailsActions

    var body: some View {
        Button(action: {
            action = runAction
        }, label: {
            ThumbnailImage(url: viewModel.thumbnailsHigh.0,
                           width: viewModel.thumbnailsHigh.1,
                           height: viewModel.thumbnailsHigh.2)
        })
        .style(appStyle: .redBorderButton)
        .frame(width: viewModel.thumbnailsHigh.1, height: viewModel.thumbnailsHigh.2)
    }
}

/// Update Broadcast button
struct UpdateBroadcastButton: View, Themeable {
    @Environment(\.colorScheme) var colorScheme
    let viewModel: VideoDetailsViewModel
    @Binding var action: VideoDetailsActions
    let runAction: VideoDetailsActions

    var body: some View {
        HStack {
            Button(action: {
                action = runAction
            }, label: {
                HStack {
                    Image(systemName: "pencil")
                        .foregroundColor(videoListPlusButtonColor)
                    Text("Update")
                        .foregroundColor(videoListPlusButtonColor)
                }
            })
        }
    }
}
