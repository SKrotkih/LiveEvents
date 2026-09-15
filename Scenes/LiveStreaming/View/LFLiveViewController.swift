//
//  LFLiveViewController.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 11/8/16.
//

import UIKit
import RxSwift

class LFLiveViewController: UIViewController {
    var viewModel: YouTubeLiveVideoPublisher!

    var scheduledStartTime: NSDate?

    @IBOutlet weak var lfView: LFLivePreview!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var beautyButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var startLiveButton: UIButton!
    @IBOutlet weak var currentStatusLabel: UILabel!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        lfView.prepareForUsing()
        startListeningToModelEvents()
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

    @MainActor
    func showCurrentStatus(currStatus: String) {
        self.currentStatusLabel.text = currStatus
    }

    @MainActor
    func showError(_ message: String) {
        Alert.showOk("Warning", message: message)
    }

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
        Task {
            let (streamUrl, scheduledStartTime) = await viewModel.willStartPublishing()
            await MainActor.run {
                self.scheduledStartTime = scheduledStartTime
                self.lfView.startPublishing(withStreamURL: streamUrl)
            }
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

    private func configureView() {
        beautyButton.isExclusiveTouch = true
        cameraButton.isExclusiveTouch = true
        closeButton.isExclusiveTouch = true
        isVideoInProcess = false
    }

    private func startListeningToModelEvents() {
        // The view model emits from the monitor's background task; UIKit must be touched on main.
        viewModel
            .rxDidUserFinishWatchVideo
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        viewModel
            .rxStateDescription
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.showCurrentStatus(currStatus: state)
            }).disposed(by: disposeBag)
        viewModel
            .rxError
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.showError(message)
            }).disposed(by: disposeBag)
    }
}
