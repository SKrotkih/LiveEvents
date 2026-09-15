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
        let task: Task<T, Error> = Task {
            let data = try Data(contentsOf: file)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let raw = try decoder.singleValueContainer().decode(String.self)
                guard let date = RFC3339.date(from: raw) else {
                    throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Bad date \(raw)"))
                }
                return date
            }
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        }
        do {
            let data = try await task.value
            return .success(data)
        } catch {
            return .failure(.message("Failed parse \(filename) as \(T.self):\n\(error)"))
        }
    }
}
