//
//  ColorSheme.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 22.11.2022.
//

import SwiftUI

///
/// Themeable protocol for customize Views by color
///
protocol Themeable {
    var colorScheme: ColorScheme { get }
}

extension Themeable {
    var fontColor: Color {
        colorScheme == .dark ? .white : .black
    }
    var homeTitleColor: Color {
        colorScheme == .dark ? .white : .black
    }
    var userNameColor: Color {
        colorScheme == .dark ? .white : .white
    }
    var logOutButtonColor: Color {
        colorScheme == .dark ? .white : .white
    }
    var videoListSectionColor: Color {
        colorScheme == .dark ? .white : .black
    }
    var videoListButtonColor: Color {
        colorScheme == .dark ? .red : .black
    }
    var videoListItemColor: Color {
        colorScheme == .dark ? .white : .black
    }
    var videoListItemDateColor: Color {
        colorScheme == .dark ? .white : .gray
    }
    var videoListPlusButtonColor: Color {
        colorScheme == .dark ? .white : .white
    }
    var backButtonColor: Color {
        colorScheme == .dark ? .white : .white
    }
    var loadingIndicatorBGColor: Color {
        colorScheme == .dark ? .white : .black
    }
    var loadingIndicatorColor: Color {
        colorScheme == .dark ? .red : .red
    }
    var addStreamSectionColor: Color {
        colorScheme == .dark ? .white : .black
    }
    var doneButtonColor: Color {
        colorScheme == .dark ? .white : .white
    }
    var menuBackgroundColor: Color {
        colorScheme == .dark ? .red : .red
    }
}
