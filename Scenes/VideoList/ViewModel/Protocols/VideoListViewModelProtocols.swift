//
//  VideoListViewModelProtocols.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 27.10.2020.
//  Copyright © 2020 Serhii Krotkykh. All rights reserved.
//

import Foundation
import RxSwift
import Combine

protocol VideoListViewModelOutput {
    func didOpenViewAction()
    func didCloseViewAction()
    func didUserLogOutAction()
    func createBroadcast()
    func didLaunchStreamAction(indexPath: IndexPath, viewController: UIViewController)
}

protocol VideoListViewModelInput {
    var errorPublisher: PassthroughSubject<String, Never> { get }
    var rxData: PublishSubject<[SectionModel]> { get }
}
