//
//  Tap List Item.swift
//  Cork
//
//  Created by David Bureš - P on 08.08.2026.
//

import ButtonKit
import CorkModels
import CorkShared
import FactoryKit
import Foundation
import SwiftUI

#warning("This does nothing for now, because the navigation is broken")
struct TapListItem: View
{
    @InjectedObservable(\.navigationManager) var navigationManager: NavigationManager
    @InjectedObservable(\.tapTracker) var tapTracker: TapTracker

    let tap: BrewTap

    var badgeView: Text?
    {
        var components: [Text] = []

        if tap.isSpeakeasySupported
        {
            components.append(Text(Image(systemName: "hare")))
        }

        // MARK: Assemble the final view

        guard !components.isEmpty else { return nil }

        return components.dropFirst().reduce(into: components[0])
        { result, text in
            result = result + Text(" | ") + text
        }
    }

    var body: some View
    {
        Group
        {
            Text(tap.name(withPrecision: .full))

            if tap.isBeingModified
            {
                Spacer()

                ProgressView()
                    .frame(height: 5)
                    .scaleEffect(0.5)
            }
        }
        .contextMenu
        {
            AsyncButton(role: .destructive)
            {
                AppConstants.shared.logger.debug("Would remove \(tap.name(withPrecision: .full), privacy: .public)")

                try await tapTracker.removeTap(tapToRemove: tap, purpose: .removeFromHomebrewAndTracker)
            } label: {
                Label("sidebar.section.added-taps.contextmenu.remove-\(tap.name(withPrecision: .full))", systemImage: "trash")
            }
            .asyncButtonStyle(.plainStyle)
        }
        .badge(badgeView)        
    }
}
