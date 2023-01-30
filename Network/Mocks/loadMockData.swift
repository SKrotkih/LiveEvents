//
//  loadMockData.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 26.05.2021.
//
import Foundation

struct DecodeData {

    static func loadMockData<T: Codable>(_ filename: String, as type: T.Type = T.self) async -> Result<T, LVError> {
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
            return .failure(.message("Failed find \(filename) in main bundle."))
        }
        let task: Task<T, Error> = Task {
            let data = try Data(contentsOf: file)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
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
