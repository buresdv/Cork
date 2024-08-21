//
//  Button - Large Button.swift
//  Cork
//
//  Created by David Bureš on 24.10.2023.
//

import SwiftUI

struct LargeButtonStyle: ButtonStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        configuration.label
            .padding(.horizontal, 27)
            .padding(.vertical, 7)
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .shadow(radius: 1)
    }
}
