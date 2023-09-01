//
//  PillText.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import SwiftUI

struct PillText: View
{
    @State var text: String
    @State var color: NSColor = .tertiaryLabelColor
    @State var font: Font = .caption
    
    var body: some View
    {
        Text(text)
            .font(font)
            .padding(.horizontal, 4)
            .background(Color(color))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

struct PillTextWithLocalizableText: View
{
    @State var localizedText: LocalizedStringKey
    @State var color: NSColor = .tertiaryLabelColor
    @State var font: Font = .caption
    
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
            .overlay(Capsule().stroke(color, lineWidth: 1))
    }
}

struct OutlinedPill<Content: View>: View
{
    @ViewBuilder var content: Content
    @State var color: Color
    
    var body: some View
    {
        content
            .font(.caption2)
            .padding(.horizontal, 4)
            .foregroundColor(color)
            .overlay(Capsule().stroke(color, lineWidth: 1))
    }
}
