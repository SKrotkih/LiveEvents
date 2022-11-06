//
//  Views.swift
//  LiveEvents
//
//  Created by Sergey Krotkih on 11/6/22.
//

import SwiftUI
import Combine

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Button(
            action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                HStack {
                    Image(systemName: "arrow.left.circle")
                        .foregroundColor(.white)
                    Text("Back")
                        .foregroundColor(.white)
                }
            })
    }
}

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
