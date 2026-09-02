//
//  Pill Text.swift
//  Cork
//
//  Created by David Bureš - P on 12.08.2026.
//

import Foundation
import SwiftUI

/*
public struct PillText: View
{
    let text: String
    let backgroundColor: NSColor
    let textColor: NSColor

    public var body: some View
    {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 4)
            .foregroundColor(Color(nsColor: textColor))
            .background(Color(nsColor: backgroundColor))
            .clipShape(Capsule())
    }
}

public struct PillTextWithLocalizableText: View
{
    let localizedText: LocalizedStringKey
    let color: NSColor
    let font: Font

    public init(localizedText: LocalizedStringKey, color: NSColor = .tertiaryLabelColor, font: Font = .caption)
    {
        self.localizedText = localizedText
        self.color = color
        self.font = font
    }

    public var body: some View
    {
        Text(localizedText)
            .font(font)
            .padding(.horizontal, 4)
            .background(Color(color))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}
 
 public struct OutlinedPillText: View
 {
     let text: LocalizedStringKey
     let color: Color

     public var body: some View
     {
         Text(text)
             .font(.caption2)
             .padding(.horizontal, 6)
             .padding(.vertical, 2)
             .foregroundColor(color)
             .overlay(RoundedRectangle(cornerRadius: 7).stroke(color, lineWidth: 1))
     }
 }
*/
 
public struct PillLabelStyle: LabelStyle
{
    public enum LabelIconStyle: Sendable
    {
        case iconIsHidden
        case iconIsShown
    }
    
    public struct LabelColor: Sendable
    {
        let text: Color
        let background: Color
        
        public init(
            text: Color,
            background: Color)
        {
            self.text = text
            self.background = background
        }
    }
    
    let color: LabelColor
    let font: Font
    let iconStyle: LabelIconStyle

    nonisolated public init(
        color: LabelColor = .init(text: .primary, background: .accentColor),
        font: Font = .caption,
        iconStyle: LabelIconStyle = .iconIsHidden
    )
    {
        self.color = color
        self.font = font
        self.iconStyle = iconStyle
    }

    public func makeBody(configuration: Configuration) -> some View
    {
        HStack(spacing: 4)
        {
            if iconStyle == .iconIsShown
            {
                configuration.icon
            }
            
            configuration.title
        }
        .font(font.bold())
        .foregroundStyle(color.text)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.background)
        .clipShape(Capsule())
    }
}

public extension LabelStyle where Self == PillLabelStyle
{
    nonisolated static func pill(
        color: PillLabelStyle.LabelColor = .init(text: .primary, background: .accentColor),
        font: Font = .caption,
        iconStyle: PillLabelStyle.LabelIconStyle = .iconIsHidden
    ) -> PillLabelStyle
    {
        PillLabelStyle(color: color, font: font, iconStyle: iconStyle)
    }
}

/// For an outline - try to find a way to merge it with the one above
public struct OutlinedPillLabelStyle: LabelStyle
{
    public enum LabelIconStyle: Sendable
    {
        case iconIsHidden
        case iconIsShown
    }
    
    let color: Color
    let font: Font
    let iconStyle: LabelIconStyle

    nonisolated public init(color: Color = .primary, font: Font = .subheadline.bold(), iconStyle: LabelIconStyle = .iconIsHidden)
    {
        self.color = color
        self.font = font
        self.iconStyle = iconStyle
    }

    public func makeBody(configuration: Configuration) -> some View
    {
        HStack(spacing: 4)
        {
            if iconStyle == .iconIsShown
            {
                configuration.icon
            }
            
            configuration.title
        }
        .font(font)
        .foregroundStyle(color)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .strokeBorder(color, lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}

public extension LabelStyle where Self == OutlinedPillLabelStyle
{
    nonisolated static func outlinedPill(
        color: Color = .primary,
        font: Font = .caption,
        iconStyle: OutlinedPillLabelStyle.LabelIconStyle = .iconIsHidden
    ) -> OutlinedPillLabelStyle
    {
        OutlinedPillLabelStyle(color: color, font: font, iconStyle: iconStyle)
    }
}
