//
//  PillText.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import SwiftUI

struct PillText: View {
    
    let text: String
    let backgroundColor: NSColor
    let textColor: NSColor
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 4)
            .foregroundColor(Color(nsColor: textColor))
            .background(Color(nsColor: backgroundColor))
            .clipShape(Capsule())
    }
}

struct PillTextWithLocalizableText: View
{
    let localizedText: LocalizedStringKey
    let color: NSColor = .tertiaryLabelColor
    let font: Font = .caption

    var body: some View
    {
        Text(localizedText)
            .font(font)
            .padding(.horizontal, 4)
            .background(Color(color))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

struct OutlinedPillText: View
{
    @State var text: LocalizedStringKey
    @State var color: Color

    var body: some View
    {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 4)
            .foregroundColor(color)
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(color, lineWidth: 1))
    }
}

struct OutlinedPill<Content: View>: View
{
    @ViewBuilder var content: Content
    let color: Color

    var body: some View
    {
        content
            .font(.caption2)
            .padding(.horizontal, 4)
            .foregroundStyle(color)
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(color, lineWidth: 1))
    }
}
