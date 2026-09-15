//
//  DisclosureGroup - No Padding.swift
//  Cork
//
//  Created by David Bureš on 26.02.2023.
//

import SwiftUI

public struct NoPadding: DisclosureGroupStyle
{
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View
    {
        Button
        {
            withAnimation
            {
                configuration.isExpanded.toggle()
            }
        }
        label:
        {
            HStack(alignment: .center, spacing: 4)
            {
                BetterDisclosureGroupChevron(configuration: configuration)

                configuration.label

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        if configuration.isExpanded
        {
            configuration.content
        }
    }
}
