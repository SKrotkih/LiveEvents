import SwiftUI
import YTLiveStreaming

struct LiveStreamView: View {
    enum Command: Equatable {
        case start(url: String)
        case stop
        case switchCamera
    }

    @StateObject private var viewModel: LiveStreamingViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var command: Command?
    @State private var isPublishing = false
    @State private var isFinishing = false

    init(broadcast: LiveBroadcastStreamModel, broadcastsAPI: YouTubeLiveClient) {
        _viewModel = StateObject(wrappedValue: LiveStreamingViewModel(broadcast: broadcast, broadcastsAPI: broadcastsAPI))
    }

    var body: some View {
        ZStack {
            LivePreviewRepresentable(onStateChange: viewModel.report(encoderState:), command: $command)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Button(action: cancel) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: { command = .switchCamera }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding()

                Spacer()

                if !viewModel.chatLines.isEmpty {
                    Text(viewModel.chatLines.joined(separator: "\n"))
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.35))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                Text(viewModel.statusText)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)

                Button(action: togglePublishing) {
                    Text(buttonTitle)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(isPublishing ? Color.gray : Color.red)
                        .cornerRadius(10)
                }
                .disabled(isFinishing)
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Warning",
               isPresented: Binding(get: { viewModel.errorMessage != nil },
                                    set: { if !$0 { viewModel.errorMessage = nil } })) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onChange(of: viewModel.isFinished) { _, finished in
            if finished { dismiss() }
        }
    }

    private var buttonTitle: String {
        if isFinishing { return "Finishing…" }
        return isPublishing ? "Finish live broadcast" : "Start live broadcast"
    }

    private func togglePublishing() {
        if isPublishing {
            command = .stop
            isPublishing = false
            isFinishing = true
            viewModel.finishPublishing()
        } else {
            Task {
                if let url = await viewModel.startPublishing() {
                    command = .start(url: url)
                    isPublishing = true
                }
            }
        }
    }

    private func cancel() {
        command = .stop
        viewModel.cancelPublishing()
    }
}
