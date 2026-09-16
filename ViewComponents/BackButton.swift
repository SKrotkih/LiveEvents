//
//  BackButton.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 22.11.2022.
//
import SwiftUI

/// Back button for the view navigation
struct BackButton: View, Themeable {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: { dismiss() }, label: {
            HStack {
                Image(systemName: "arrow.left.circle")
                    .foregroundColor(backButtonColor)
                Text("Back")
                    .foregroundColor(backButtonColor)
            }
        })
    }
}
