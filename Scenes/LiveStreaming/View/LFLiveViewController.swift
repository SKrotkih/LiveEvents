//
//  LFLiveViewController.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 11/8/16.
//

import UIKit
import Combine
import YTLiveStreaming

/// Camera screen: publishes to YouTube over RTMP (HaishinKit), shows the broadcast status
/// from `monitor(broadcastID:)` and the live chat once the broadcast is on air.
class LFLiveViewController: UIViewController {
    var viewModel: YouTubeLiveVideoPublisher!

    var scheduledStartTime: Date?

    @IBOutlet weak var lfView: LivePreviewView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var beautyButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var startLiveButton: UIButton!
    @IBOutlet weak var currentStatusLabel: UILabel!

    private let chatLabel = UILabel()
    private var recentChat: [String] = []
    private let maxChatLines = 6
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureChatOverlay()
        startListeningToModelEvents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lfView.prepareForUsing()
    }

    @IBAction func changeCameraPositionButtonPressed(_ sender: Any) {
        lfView.changeCameraPosition()
    }

    @IBAction func changeBeautyButtonPressed(_ sender: Any) {
        beautyButton.isSelected = lfView.changeBeauty()
    }

    @IBAction func onClickPublish(_ sender: Any) {
        handleClickOnPublishingButton()
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        viewModel.didUserCancelPublishingVideo()
    }

    func showCurrentStatus(currStatus: String) {
        currentStatusLabel.text = currStatus
    }

    func showError(_ message: String) {
        Alert.showOk("Warning", message: message)
    }

    // MARK: - Publishing

    private func handleClickOnPublishingButton() {
        isVideoInProcess.toggle()
        if isVideoInProcess {
            startPublishing()
        } else {
            stopPublishing()
        }
    }

    private var isVideoInProcess: Bool = false {
        didSet {
            startLiveButton.isSelected = isVideoInProcess
            startLiveButton.setTitle(isVideoInProcess ? "Finish live broadcast" : "Start live broadcast", for: .normal)
        }
    }

    private func startPublishing() {
        Task { @MainActor in
            let (streamUrl, scheduledStartTime) = await viewModel.willStartPublishing()
            self.scheduledStartTime = scheduledStartTime
            self.lfView.startPublishing(withStreamURL: streamUrl)
        }
    }

    private func stopPublishing() {
        lfView.stopPublishing()
        // YouTube treats `complete` as final: the same broadcast cannot go live again,
        // so the button stays disabled until the view model dismisses the screen.
        startLiveButton.isEnabled = false
        startLiveButton.setTitle("Finishing…", for: .disabled)
        viewModel.finishPublishing()
    }

    // MARK: - Setup

    private func configureView() {
        beautyButton.isExclusiveTouch = true
        cameraButton.isExclusiveTouch = true
        closeButton.isExclusiveTouch = true
        beautyButton.isHidden = true   // no beauty filter with HaishinKit
        isVideoInProcess = false

        lfView.onStateChange = { [weak self] state in
            switch state {
            case .connecting:  self?.showCurrentStatus(currStatus: "connecting to YouTube…")
            case .publishing:  self?.showCurrentStatus(currStatus: "sending video, waiting for YouTube…")
            case .failed(let code): self?.showError("Encoder error: \(code)")
            case .idle, .stopped: break
            }
        }
    }

    private func configureChatOverlay() {
        chatLabel.numberOfLines = maxChatLines
        chatLabel.font = .systemFont(ofSize: 14)
        chatLabel.textColor = .white
        chatLabel.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        chatLabel.layer.cornerRadius = 8
        chatLabel.clipsToBounds = true
        chatLabel.isHidden = true
        chatLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chatLabel)
        NSLayoutConstraint.activate([
            chatLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            chatLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            chatLabel.bottomAnchor.constraint(equalTo: currentStatusLabel.topAnchor, constant: -12)
        ])
    }

    private func startListeningToModelEvents() {
        // The view model emits from background tasks; UIKit must be touched on main.
        viewModel.didFinish
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.dismiss(animated: true) }
            .store(in: &cancellables)
        viewModel.stateDescription
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.showCurrentStatus(currStatus: state) }
            .store(in: &cancellables)
        viewModel.errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in self?.showError(message) }
            .store(in: &cancellables)
        viewModel.chatMessages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] batch in self?.appendChat(batch) }
            .store(in: &cancellables)
    }

    private func appendChat(_ batch: [LiveChatMessage]) {
        for message in batch where !message.text.isEmpty {
            recentChat.append("\(message.authorName): \(message.text)")
        }
        recentChat = Array(recentChat.suffix(maxChatLines))
        chatLabel.text = "  " + recentChat.joined(separator: "\n  ") + "  "
        chatLabel.isHidden = recentChat.isEmpty
    }
}
