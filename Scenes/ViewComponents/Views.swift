//
//  Views.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 11/6/22.
//

import SwiftUI
import Combine

/**
 Back button for the view navigation
 */
struct BackButton: View, Themeable {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(
            action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                HStack {
                    Image(systemName: "arrow.left.circle")
                        .foregroundColor(backButtonColor)
                    Text("Back")
                        .foregroundColor(backButtonColor)
                }
            })
    }
}

/**
 Enter just decimal symbols
 */
func decimalTextField(_ title: String, _ bindingString: Binding<String>) -> some View {
    TextField(title, text: bindingString)
        .keyboardType(.numberPad)
        .onReceive(Just(bindingString.wrappedValue)) { newValue in
            let filtered = newValue.filter { "0123456789".contains($0) }
            if filtered != newValue {
                bindingString.wrappedValue = filtered
            }
        }
}

/**
 Themeable protocol for customize Views by color
 */
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
        colorScheme == .dark ? .white : .red
    }
    var logOutButtonColor: Color {
        colorScheme == .dark ? .white : .black
    }
    var videoListSectionColor: Color {
        colorScheme == .dark ? .white : .black
    }
    var videoListItemColor: Color {
        colorScheme == .dark ? .green : .red
    }
    var videoListPlusButtonColor: Color {
        colorScheme == .dark ? .white : .black
    }
    var backButtonColor: Color {
        colorScheme == .dark ? .white : .black
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
        colorScheme == .dark ? .white : .black
    }
}
