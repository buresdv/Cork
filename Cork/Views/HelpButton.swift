//
//  HelpButton.swift
//  Cork
//
//  Created by David Bureš on 09.02.2023.
//

import SwiftUI

struct HelpButton: View {
    var action : () -> Void

    var body: some View {
        Button(action: action, label: {
            ZStack {
                Circle()
                    .strokeBorder(Color(NSColor.controlShadowColor), lineWidth: 0.5)
                    .background(Circle().foregroundColor(Color(NSColor.controlColor)))
                    .shadow(color: Color(NSColor.controlShadowColor).opacity(0.3), radius: 1)
                    .frame(width: 20, height: 20)
                Text("?").font(.system(size: 15, weight: .medium ))
            }
        })
        .buttonStyle(PlainButtonStyle())
    }
}
