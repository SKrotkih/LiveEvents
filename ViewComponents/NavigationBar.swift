//
//  NavigationBar.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 22.11.2022.
//
import SwiftUI

/// Customized navigation bar. Used as a modifier for views
struct NavigationBar: ViewModifier, Themeable {
    var title: String
    var foregroundColor: Color

    @Environment(\.colorScheme) var colorScheme

    init(title: String,
         backgroundColor: UIColor,
         foregroundColor: UIColor,
         shadowColor: UIColor,
         hideSeparator: Bool,
         tintColor: UIColor) {
        self.title = title
        self.foregroundColor = Color(foregroundColor)
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: foregroundColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: foregroundColor]
        appearance.backgroundColor = backgroundColor
        appearance.shadowColor = shadowColor
        if hideSeparator {
            appearance.shadowColor = .clear
        }
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = tintColor
    }
    
    func body(content: Content) -> some View {
        content
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(title)
                            .bold()
                            .foregroundColor(foregroundColor)
                    }
                }
            }
            .statusBar(hidden: true)
    }
}

extension View {
    func navigationBar(title: String,
                       backgroundColor: UIColor = .red,
                       foregroundColor: UIColor = .white,
                       shadowColor: UIColor = .black,
                       hideSeparator: Bool = true,
                       tintColor: UIColor = .white) -> some View {
        self.modifier(NavigationBar(title: title,
                                    backgroundColor: backgroundColor,
                                    foregroundColor: foregroundColor,
                                    shadowColor: shadowColor,
                                    hideSeparator: hideSeparator,
                                    tintColor: tintColor))
    }
}
