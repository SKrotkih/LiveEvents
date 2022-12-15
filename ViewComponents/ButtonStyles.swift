//
//  ButtonStyles.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh
//

import Foundation
import SwiftUI
///
/// App Button Styles
///
extension Button {
    enum AppButtonStyle {
        case redBorderButton
        case noStyle
    }
    
    func style(appStyle: AppButtonStyle) -> some View {
        Group {
            switch appStyle {
            case .redBorderButton:
                redBorderButton()
            case .noStyle:
                noStyleButton()
            }
        }
    }
}

extension Button {
    private func redBorderButton() -> some View {
        self.background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.red, lineWidth: 2)
        )
        .shadow(color: .white, radius: 10, y: 5)
    }

    private func noStyleButton() -> some View {
        self
    }
}
