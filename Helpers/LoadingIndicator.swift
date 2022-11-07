//
//  LoadingIndicator.swift
//  LiveEvents
//

import SwiftUI

struct LoadingIndicator: ViewModifier, Themeable {
    @Environment(\.colorScheme) var colorScheme

    @State private var isCircleRotating = true
    @State private var animateStart = false
    @State private var animateEnd = true

    var isShowing: Bool

    private var loadingView: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: Settings.background.borderWidth)
                .fill(loadingIndicatorBGColor)
                .frame(width: Settings.background.size.width,
                       height: Settings.background.size.height)
            Circle()
                .trim(from: animateStart ? 1/3 : 1/9, to: animateEnd ? 2/5 : 1)
                .stroke(lineWidth: Settings.foreground.borderWidth)
                .rotationEffect(.degrees(isCircleRotating ? 360 : 0))
                .frame(width: Settings.foreground.size.width,
                       height: Settings.foreground.size.height)
                .foregroundColor(loadingIndicatorColor)
                .onAppear {
                    withAnimation(Animation
                                    .linear(duration: 1)
                                    .repeatForever(autoreverses: false)) {
                        self.isCircleRotating.toggle()
                    }
                    withAnimation(Animation
                                    .linear(duration: 1)
                                    .delay(0.5)
                                    .repeatForever(autoreverses: true)) {
                        self.animateStart.toggle()
                    }
                    withAnimation(Animation
                                    .linear(duration: 1)
                                    .delay(1)
                                    .repeatForever(autoreverses: true)) {
                        self.animateEnd.toggle()
                    }
                }
        }
        .padding(.top, Settings.offset)
    }
}

extension LoadingIndicator {
    enum Settings {
        case background
        case foreground

        struct Size {
            let width: CGFloat
            let height: CGFloat
        }

        var size: Size {
            switch self {
            case .background:
                return Size(width: 75.0, height: 75.0)
            case .foreground:
                return Size(width: 75.0, height: 75.0)
            }
        }

        var borderWidth: CGFloat {
            switch self {
            case .background:
                return 10.0
            case .foreground:
                return 10.0
            }
        }

        static var offset: CGFloat {
            return 150.0
        }
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                loadingView
            }
        }
    }
}

extension View {
    func loadingIndicator(_ isShowing: Bool) -> some View {
        self.modifier(LoadingIndicator(isShowing: isShowing))
    }
}
