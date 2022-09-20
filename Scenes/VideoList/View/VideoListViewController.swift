//
//  VideoListViewController.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import UIKit
import YTLiveStreaming
import RxCocoa
import RxDataSources
import RxSwift
import Combine

struct Stream {
    var time: String
    var name: String
}

// Here the user can see video list on three sections: past, current live video and scheduled
// He can select list item to watch past and current and create a new video
class VideoListViewController: BaseViewController {

    @Lateinit var store: AuthStore

    @Lateinit var output: VideoListViewModelOutput
    @Lateinit var input: VideoListViewModelInput

    enum CellIdentifier: String {
        case videoListCell
    }

    @IBOutlet weak var createBroadcastButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var addNewStreamButton: UIButton!

    fileprivate var refreshControl: UIRefreshControl!

    var dataSource: Any?

    private let disposeBag = DisposeBag()
    private var disposables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bindInput()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureLeftBarButtonItem()
        configureRightBarButtonItem()
    }

    private func configureView() {
        configureAddStreamButton()
        setUpRefreshControl()
        bindUserActivity()
        bindTableViewData()
        output.didOpenViewAction()
    }

    private func closeView() {
        output.didCloseViewAction()
    }

    private func didUserLogOut() {
        stopActivity()
        closeView()
        Router.openMainScreen()
    }

    @objc private func backButtonPressed() {
        stopActivity()
        closeView()
    }

    func showError(message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Alert.showOk("Error", message: message)
        }
    }
}

// MARK: - Activity Indicator

extension VideoListViewController {
    func startActivity() {
        DispatchQueue.performUIUpdate { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }

    func stopActivity() {
        DispatchQueue.performUIUpdate { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
}

// MARK: - Bind Input/Output

extension VideoListViewController {
    private func bindInput() {
        input
            .rxData
            .bind(to: tableView
                    .rx
                    .items(dataSource: dataSource as! RxTableViewSectionedReloadDataSource<SectionModel>))
            .disposed(by: disposeBag)
        input
            .rxData
            .subscribe(onNext: { _ in
                DispatchQueue.performUIUpdate { [weak self] in
                    self?.refreshControl.endRefreshing()
                }
            }).disposed(by: disposeBag)
        // Combine way
        input
            .errorPublisher
            .sink(receiveValue: { [weak self] message in
                self?.showError(message: message)
            })
            .store(in: &disposables)

        // listening to result of log out
        store
            .$state
            .sink { [weak self] state in
                if !state.isConnected {
                    self?.didUserLogOut()
                }
            }
            .store(in: &disposables)
    }

    private func bindUserActivity() {
        addNewStreamButton
            .rx
            .tap
            .debounce(.milliseconds(Constants.UiConstraints.debounce), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.output.createBroadcast()
            }).disposed(by: disposeBag)
    }

    private func bindTableViewData() {
        tableView.delegate = self
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel>(
            configureCell: { (_, tableView, _, element) in
                if let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.videoListCell.rawValue) as? VideoListTableViewCell {
                    cell.nameLabel.text = element.snippet.title
                    let publishedAt = element.snippet.publishedAt
                    cell.beginLabel.text = "start: \(publishedAt)"
                    return cell
                } else {
                    return UITableViewCell()
                }
            },
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource[sectionIndex].model
            }
        )
    }
}

// MARK: UiTableView delegates. didSelectRow

extension VideoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        output.didLaunchStreamAction(indexPath: indexPath, viewController: self)
    }
}

// MARK: - Configure View Items

extension VideoListViewController {
    private func configureLeftBarButtonItem() {
        let backButton = UIBarButtonItem.init(title: "Back",
                                              style: .plain,
                                              target: self,
                                              action: #selector(backButtonPressed))
        self.navigationItem.leftBarButtonItem = backButton
    }

    private func configureRightBarButtonItem() {
        let userNameLabel = UILabel(frame: CGRect.zero)
        userNameLabel.text = store.state.userSession?.profile.fullName ?? ""
        userNameLabel.textColor = .white
        let rightBarButton = UIBarButtonItem(customView: userNameLabel)
        self.navigationItem.rightBarButtonItem = rightBarButton
    }

    private func configureAddStreamButton() {
        self.addNewStreamButton = UIButton(frame: CGRect(x: 0, y: 0, width: 55.0, height: 55.0))
        addNewStreamButton.setImage(#imageLiteral(resourceName: "addStreamButton"), for: .normal)
        self.view.addSubview(addNewStreamButton)
        addNewStreamButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addNewStreamButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40.0),
            addNewStreamButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20.0)
        ])
    }
}

// MARK: Refresh Controller

extension VideoListViewController {
    private func setUpRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.red
        self.refreshControl.addTarget(self,
                                      action: #selector(VideoListViewController.refreshData(_:)),
                                      for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)
    }

    @objc func refreshData(_ sender: AnyObject) {
        output.didOpenViewAction()
    }
}
