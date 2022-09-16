//  YTVideoPlayer.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

class YTVideoPlayer: YouTubeVideoPlayed {
    var completion: ((Result<Void, LVError>) -> Void)?
    func playVideo(_ videoId: String,
                   viewController: UIViewController,
                   _ completion: @escaping (Result<Void, LVError>) -> Void) {
        self.completion = completion
        Router.playVideo(with: videoId)
    }
}
