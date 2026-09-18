import UIKit
import AVFoundation
import HaishinKit

/// What the encoder is doing, for the status label.
enum PublishingState: Equatable {
    case idle
    case connecting
    case publishing
    case failed(String)
    case stopped
}

final class LivePreviewView: UIView {
    var onStateChange: ((PublishingState) -> Void)?

    private let connection = RTMPConnection()
    private lazy var stream = RTMPStream(connection: connection)
    private lazy var previewView = MTHKView(frame: bounds)
    private var cameraPosition: AVCaptureDevice.Position = .back
    private var streamKey = ""
    private var isConfigured = false

    // MARK: - Public API (same surface the view controller used with LFLivePreview)

    /// Requests camera/microphone access and starts the preview.
    func prepareForUsing() {
        guard !isConfigured else { return }
        isConfigured = true
        embedPreview()
        connection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        requestAccess(for: .video) { [weak self] granted in
            guard granted else { return }
            self?.requestAccess(for: .audio) { _ in
                DispatchQueue.main.async { self?.attachDevices() }
            }
        }
    }

    func changeCameraPosition() {
        cameraPosition = cameraPosition == .back ? .front : .back
        stream.attachCamera(camera(cameraPosition)) { @Sendable _, error in
            if let error { print("attachCamera:", error) }
        }
    }

    /// HaishinKit ships no beauty filter; kept for API compatibility. Always off.
    func changeBeauty() -> Bool { false }

    /// `rtmp://host/app/streamKey` as returned by YouTube (`ingestionAddress/streamName`).
    func startPublishing(withStreamURL streamURL: String?) {
        guard let streamURL, let url = URL(string: streamURL) else {
            onStateChange?(.failed("Missing stream URL"))
            return
        }
        // Split "rtmp://a.rtmp.youtube.com/live2/<key>" into the app URL and the key.
        streamKey = url.lastPathComponent
        let appURL = url.deletingLastPathComponent().absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        onStateChange?(.connecting)
        connection.connect(appURL)
    }

    func stopPublishing() {
        stream.close()
        connection.close()
        onStateChange?(.stopped)
    }

    /// Called from the SwiftUI representable's `dismantleUIView`; `deinit` cannot touch the
    /// non-Sendable RTMP objects in Swift 6, so cleanup happens here on the main actor.
    func teardown() {
        connection.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        stream.close()
        connection.close()
    }

    // MARK: - Setup

    private func embedPreview() {
        previewView.videoGravity = .resizeAspectFill
        previewView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(previewView, at: 0)
        NSLayoutConstraint.activate([
            previewView.leadingAnchor.constraint(equalTo: leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: trailingAnchor),
            previewView.topAnchor.constraint(equalTo: topAnchor),
            previewView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        previewView.attachStream(stream)
    }

    private func attachDevices() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try? session.setActive(true)

        stream.videoSettings.videoSize = .init(width: 720, height: 1280)
        stream.videoSettings.bitRate = 2_500_000
        stream.videoSettings.maxKeyFrameIntervalDuration = 2
        stream.audioSettings.bitRate = 128_000

        stream.attachAudio(AVCaptureDevice.default(for: .audio)) { @Sendable _, error in
            if let error { print("attachAudio:", error) }
        }
        stream.attachCamera(camera(cameraPosition)) { @Sendable _, error in
            if let error { print("attachCamera:", error) }
        }
    }

    private func camera(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
    }

    private func requestAccess(for mediaType: AVMediaType, completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: completion)
        default:
            completion(false)
        }
    }

    // MARK: - RTMP status

    /// HaishinKit posts `.rtmpStatus` from its own queue, so the observer must not be
    /// MainActor-isolated (Swift 6 traps otherwise). Extract the code here, then hop to main.
    @objc nonisolated private func rtmpStatusHandler(_ notification: Notification) {
        let event = Event.from(notification)
        guard let data = event.data as? ASObject, let code = data["code"] as? String else { return }
        print("RTMP status:", code)
        Task { @MainActor [weak self] in self?.handleRTMPStatus(code) }
    }

    private func handleRTMPStatus(_ code: String) {
        switch code {
        case RTMPConnection.Code.connectSuccess.rawValue:
            stream.publish(streamKey)
        case RTMPStream.Code.publishStart.rawValue:
            onStateChange?(.publishing)
        case RTMPConnection.Code.connectFailed.rawValue,
             RTMPConnection.Code.connectClosed.rawValue,
             RTMPStream.Code.publishBadName.rawValue:
            onStateChange?(.failed(code))
        default:
            break
        }
    }
}
