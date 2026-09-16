//
//  VideoListView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//
import SwiftUI
import YTLiveStreaming

/// Sectioned list of the channel's broadcasts.
struct VideoListView: View {
    @EnvironmentObject var viewModel: VideoListViewModel
    @State private var isSideMenuShowing = false
    @State private var selectMode = false
    @State private var selectedIDs: [String] = []
    @State private var showDeleteAlert = false
    @State private var showFailedDeleteAlert = false
    @State private var deleteErrorMessage = ""

    private var showLoadError: Binding<Bool> {
        Binding(get: { !viewModel.errorMessage.isEmpty },
                set: { if !$0 { viewModel.errorMessage = "" } })
    }

    var body: some View {
        contentView
            .task {
                if viewModel.sections.isEmpty { await viewModel.loadData() }
            }
            .refreshable { await viewModel.loadData() }
            .sideMenu(isShowing: $isSideMenuShowing) {
                MenuContent(isShowing: $isSideMenuShowing)
            }
            .navigationBar(title: "My live video")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SideMenuButton(isSideMenuShown: $isSideMenuShowing)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NewStreamButton()
                }
            }
            .alert("Do you really want to delete \(selectedIDs.count) items?", isPresented: $showDeleteAlert) {
                Button("OK") { deleteSelectedItems() }
                Button("Cancel", role: .cancel) { exitSelectMode() }
            }
            .alert(deleteErrorMessage, isPresented: $showFailedDeleteAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Could not load broadcasts", isPresented: showLoadError) {
                Button("Retry") { Task { await viewModel.loadData() } }
                Button("OK", role: .cancel) { viewModel.errorMessage = "" }
            } message: {
                Text(viewModel.errorMessage)
            }
    }

    private var contentView: some View {
        VStack {
            HStack {
                if selectMode {
                    Button("Delete \(selectedIDs.count) items") {
                        showDeleteAlert = !selectedIDs.isEmpty
                    }
                    .padding(.leading, 15.0)
                } else {
                    Button("Select") { selectMode.toggle() }
                        .padding(.leading, 15.0)
                }
                Spacer()
            }
            .padding(10.0)
            .foregroundColor(.black)
            VideoList(viewModel: viewModel, selectMode: $selectMode, selectedIDs: $selectedIDs)
        }
        .loadingIndicator(viewModel.isDataDownloading)
    }

    private func deleteSelectedItems() {
        Task {
            do {
                try await viewModel.deleteBroadcasts(selectedIDs)
            } catch {
                deleteErrorMessage = error.localizedDescription
                showFailedDeleteAlert = true
            }
            exitSelectMode()
        }
    }

    private func exitSelectMode() {
        selectedIDs.removeAll()
        selectMode = false
    }
}

/// The list itself.
struct VideoList: View, Themeable {
    @ObservedObject var viewModel: VideoListViewModel
    @Binding var selectMode: Bool
    @Binding var selectedIDs: [String]
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        List {
            ForEach(viewModel.sections) { section in
                Section {
                    ForEach(section.rows) { item in
                        let detailsViewModel = VideoDetailsViewModel(videoDetails: item.model)
                        NavigationLink(destination: VideoDetailsView(viewModel: detailsViewModel)) {
                            ListRow(item: item, selectMode: $selectMode, selectedIDs: $selectedIDs)
                        }
                    }
                } header: {
                    Text(section.sectionName)
                        .font(.system(size: 16))
                        .foregroundColor(videoListSectionColor)
                }
            }
        }
        .listStyle(.grouped)
    }

    struct ListRow: View, Themeable {
        @Environment(\.colorScheme) var colorScheme
        let item: VideoListRow
        @Binding var selectMode: Bool
        @Binding var selectedIDs: [String]

        var body: some View {
            HStack(alignment: .center) {
                if selectMode {
                    Image(systemName: selectedIDs.contains(item.model.id) ? "checkmark.square" : "square")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30.0, height: 30.0)
                        .foregroundColor(.black)
                        .onTapGesture { toggleSelection() }
                    Spacer(minLength: 5.0)
                }
                ThumbnailImage(url: item.model.snippet.thumbnails?.defaultThumbnail?.url, width: 40, height: 40)
                Spacer(minLength: 5.0)
                VStack {
                    HStack {
                        Text(item.model.snippet.title)
                            .foregroundColor(videoListItemColor)
                        Spacer()
                    }
                    HStack {
                        Text(item.model.snippet.description)
                            .foregroundColor(videoListItemDateColor)
                            .font(.system(size: 12))
                        Spacer()
                    }
                }
                Spacer(minLength: 5.0)
                Text(item.model.snippet.publishedAt.fullDateFormat)
                    .foregroundColor(videoListItemDateColor)
                    .font(.system(size: 12))
                    .frame(width: 70.0)
                Spacer()
            }
            .font(.system(size: 14))
            .padding(.vertical, 4.0)
        }

        private func toggleSelection() {
            if let index = selectedIDs.firstIndex(of: item.model.id) {
                selectedIDs.remove(at: index)
            } else {
                selectedIDs.append(item.model.id)
            }
        }
    }
}

/// Opens the "schedule a new broadcast" screen.
struct NewStreamButton: View, Themeable {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationLink(destination: NewBroadcastView()) {
            HStack {
                Image(systemName: "plus.app")
                Text("Add")
            }
            .foregroundColor(videoListPlusButtonColor)
        }
    }
}

#Preview {
    let environment = AppEnvironment()
    let dataSource = BroadcastListFetcher(broadcastsAPI: environment.youtube)
    NavigationStack {
        VideoListView()
            .environmentObject(environment.store)
            .environmentObject(VideoListViewModel(store: environment.store, dataSource: dataSource))
            .environmentObject(MenuViewModel(store: environment.store))
    }
}
