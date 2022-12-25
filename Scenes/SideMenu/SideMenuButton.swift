//
//  SideMenuButton.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 22.11.2022.
//
import SwiftUI
///
/// Side Menu button for the view navigation
///
struct SideMenuButton: View, Themeable {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Binding var isSideMenuShown: Bool
    
    var body: some View {
        Button(
            action: {
                isSideMenuShown.toggle()
            }, label: {
                HStack {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                        .foregroundColor(.black)
                }
            })
    }
}
