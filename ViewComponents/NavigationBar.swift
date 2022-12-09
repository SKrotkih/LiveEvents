//
//  NavigationBar.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 22.11.2022.
//

import SwiftUI

///
/// Customized navigation bar. Used as a modifier for views
///
struct NavigationBar: ViewModifier, Themeable {
    var title: String
    
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle(Text(title), displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .statusBar(hidden: true)
    }
}

extension View {
    func navigationBar(title: String) -> some View {
        self.modifier(NavigationBar(title: title))
    }
}
