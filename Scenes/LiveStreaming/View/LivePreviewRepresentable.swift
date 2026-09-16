//
//  LivePreviewRepresentable.swift
//  LiveEvents
//
//  Bridges the HaishinKit-based `LivePreviewView` (UIKit) into SwiftUI and exposes
//  imperative controls through a coordinator.
//

import SwiftUI

struct LivePreviewRepresentable: UIViewRepresentable {
    final class Coordinator {
        weak var view: LivePreviewView?
    }

    let onStateChange: (PublishingState) -> Void
    @Binding var command: LiveStreamView.Command?
    let coordinator = Coordinator()

    func makeCoordinator() -> Coordinator { coordinator }

    func makeUIView(context: Context) -> LivePreviewView {
        let view = LivePreviewView()
        view.onStateChange = { state in
            DispatchQueue.main.async { onStateChange(state) }
        }
        context.coordinator.view = view
        view.prepareForUsing()
        return view
    }

    func updateUIView(_ uiView: LivePreviewView, context: Context) {
        guard let command else { return }
        switch command {
        case .start(let url):    uiView.startPublishing(withStreamURL: url)
        case .stop:              uiView.stopPublishing()
        case .switchCamera:      uiView.changeCameraPosition()
        }
        DispatchQueue.main.async { self.command = nil }
    }
}
