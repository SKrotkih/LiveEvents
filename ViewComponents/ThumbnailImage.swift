//
//  ThumbnailImage.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 24.12.2022.
//  Copyright © 2022 Serhii Krotkykh. All rights reserved.
//
import Foundation
import SwiftUI

struct ThumbnailImage: View {
    let url: String?
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        if let url {
            AsyncImage(
                url: URL(string: url),
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: width, maxHeight: height)
                },
                placeholder: {
                    ProgressView()
                }
            )
        } else {
            EmptyView()
        }
    }
}
