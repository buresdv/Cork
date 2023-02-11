//
//  PillText.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import SwiftUI

struct PillText: View {
    @State var text: String
    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 4)
            .background(Color(NSColor.tertiaryLabelColor))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}
