import SwiftUI

struct UpdateBroadcastView: View {
    @ObservedObject var viewModel: VideoDetailsViewModel
    @State private var model: BroadcastModel

    init(viewModel: VideoDetailsViewModel) {
        self.viewModel = viewModel
        _model = State(initialValue: viewModel.broadcastModel)
    }

    var body: some View {
        BroadcastContentView(update: true, model: $model)
            .navigationBar(title: "Update broadcast data")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { BackButton() }
            }
    }
}
