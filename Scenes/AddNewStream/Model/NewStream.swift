//
//  NewStream.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 24.03.2021.
//

import Foundation

struct NewStream {
    var title = ""
    var description = ""
    var hours = ""
    var minutes = ""
    var seconds = ""
    var date = Date()

    func verification() -> Result<Void, LVError> {
        if title.isEmpty {
            return .failure(.message("The Live Event Title is empty"))
        } else if startStreaming <= Date() {
            return .failure(.message("Start Live Event time is wrong"))
        } else {
            return .success(Void())
        }
    }

    var runAt: String {
        startStreaming.streamDateFormat
    }

    var startStreaming: Date {
        let h = hours.isEmpty ? 0 : Int(hours) ?? 0
        let m = minutes.isEmpty ? 0 : Int(minutes) ?? 0
        let s = seconds.isEmpty ? 0 : Int(seconds) ?? 0
        if h + m + s > 0 {
            return Date().add(hours: h > 24 ? 0 : h, minutes: m > 60 ? 0 : m, seconds: s > 60 ? 0 : s)
        } else {
            return date
        }
    }
}