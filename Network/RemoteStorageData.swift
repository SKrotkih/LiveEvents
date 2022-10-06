//
//  RemoteStorageData.swift
//  LiveEvents
//

import Foundation
import Combine

struct RemoteStorageData {
    static func fetch(urlData: String) -> AnyPublisher<Data, LVError> {
        guard let url = URL(string: urlData) else {
            return Fail(error: LVError.message("Invalid URL")).eraseToAnyPublisher()
        }
        let request = URLRequest(url: url)
        return URLSession.DataTaskPublisher(request: request, session: .shared)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw LVError.message("System Error")
                }
                return data
            }
            .mapError { error in
                if let error = error as? LVError {
                    return error
                } else {
                    return LVError.message(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}
