//
//  loadMockData.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 26.05.2021.
//
import Foundation
import YTLiveStreaming

struct DecodeData {

    static func loadMockData<T: Codable>(_ filename: String, as type: T.Type = T.self) async -> Result<T, LVError> {
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
            return .failure(.message("Failed find \(filename) in main bundle."))
        }
        do {
            let data = try Data(contentsOf: file)
            // The library's decoder knows the API's RFC 3339 date forms.
            let decoded = try JSONDecoder.youtubeLive().decode(T.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(.message("Failed parse \(filename) as \(T.self):\n\(error)"))
        }
    }
}
