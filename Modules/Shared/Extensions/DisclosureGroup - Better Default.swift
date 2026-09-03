//
//  DisclosureGroup - Better Default.swift
//  Cork
//
//  Created by David Bureš - P on 01.09.2026.
//

import Defaults
import SwiftUI

private extension DisclosureGroupStyle where Self == BetterDefault
{
    /// Style that provides better open/close animations
    ///
    /// Apply using the ``betterDisclosureGroupStyle()`` modifier
    static var betterDefault: BetterDefault
    {
        BetterDefault()
    }
}

public struct BetterDisclosureGroupChevron: View
{
    let configuration: DisclosureGroupStyleConfiguration

    public var body: some View
    {
        Image(systemName: "chevron.forward")
            .font(.system(size: 9, weight: .heavy, design: .default))
            .foregroundStyle(Color(nsColor: NSColor.labelColor))
            .rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))
            .animation(.smooth(duration: 0.2), value: configuration.isExpanded)
    }
}

public struct BetterDisclosureGroupContent: View
{
    let configuration: DisclosureGroupStyleConfiguration

    public var body: some View
    {
        VStack
        {
            if configuration.isExpanded
            {
                configuration.content
                    .transition(
                        .move(edge: .top).combined(with: .opacity)
                    )
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .clipped()
    }
}

struct BetterDefault: DisclosureGroupStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        VStack(alignment: .leading, spacing: 4)
        {
            Button
            {
                withAnimation(.smooth)
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
                }
                .padding(.top, 4)
                .padding(.bottom, 0)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            BetterDisclosureGroupContent(configuration: configuration)
        }
    }
}

public struct BetterDisclosureGroupApplicationModifier: ViewModifier
{
    @Environment(\.accessibilityReduceMotion) var accessibilityReduceMotion: Bool
    
    @Default(.enableExtraAnimations) var enableExtraAnimations: Bool

    public func body(content: Content) -> some View
    {
        if !accessibilityReduceMotion
        {
            disclosureGroupContent(content: content)
        }
        else
        {
            disclosureGroupContent(content: content)
                .allAnimationsDisabled()
        }
    }
    
    @ViewBuilder
    private func disclosureGroupContent(content: Content) -> some View
    {
        if enableExtraAnimations
        {
            content
                .disclosureGroupStyle(.betterDefault)
        }
        else
        {
            content
        }
    }
}

public extension DisclosureGroup
{
    /// Apply better ``DisclosureGroup`` animations that automatically adapt to the user's ``enableExtraAnimations`` setting
    ///
    /// If ``enableExtraAnimations`` is `true`, returns custom slide-in animation. If `false`, use the default animation
    @MainActor
    func betterDisclosureGroupStyle() -> some View
    {
        modifier(BetterDisclosureGroupApplicationModifier())
    }
}
