//
//  DecimalTextField.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 11/6/22.
//

import SwiftUI
import Combine
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
