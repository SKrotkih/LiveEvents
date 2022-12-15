//
//  ResultBuilder.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 13.12.2022.
//

import Foundation

@resultBuilder
struct AutolayoutBuilder {
    
    static func buildBlock(_ components: NSLayoutConstraint...) -> [NSLayoutConstraint] {
        components
    }
}
