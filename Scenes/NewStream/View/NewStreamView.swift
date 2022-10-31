//
//  NewStreamView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 10/14/22.
//

import SwiftUI

struct NewStreamView: View {
    let viewModel: NewStreamViewModel

    init(viewModel: NewStreamViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Text("New Stream")
        }
        .padding(.top, 30.0)
        .navigationBarTitle(Text("New stream"), displayMode: .inline)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .onAppear {
        }
    }
}
