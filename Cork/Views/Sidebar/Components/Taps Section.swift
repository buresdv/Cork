//
//  Taps Section.swift
//  Cork
//
//  Created by David Bureš on 03.06.2023.
//

import CorkShared
import SwiftUI
import ButtonKit

struct TapsSection: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var availableTaps: TapTracker

    let searchText: String

    var body: some View
    {
        Section("sidebar.section.added-taps")
        {
            if appState.failedWhileLoadingTaps
            {
                HStack
                {
                    Image("custom.spigot.badge.xmark")
                    Text("error.package-loading.could-not-load-taps.title")
                }
            }
            else
            {
                if appState.isLoadingTaps
                {
                    ProgressView()
                }
                else
                {
                    ForEach(displayedTaps)
                    { tap in
                        NavigationLink(value: tap)
                        {
                            Text(tap.name)

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
                            AsyncButton
                            {
                                AppConstants.shared.logger.debug("Would remove \(tap.name, privacy: .public)")

                                try await removeTap(name: tap.name, availableTaps: availableTaps, appState: appState, shouldApplyUninstallSpinnerToRelevantItemInSidebar: true)
                            } label: {
                                Text("sidebar.section.added-taps.contextmenu.remove-\(tap.name)")
                            }
                            .asyncButtonStyle(.plainStyle)
                        }
                    }
                }
            }
        }
    }

    private var displayedTaps: [BrewTap]
    {
        if searchText.isEmpty || searchText.contains("#")
        {
            return availableTaps.addedTaps
        }
        else
        {
            return availableTaps.addedTaps.filter { $0.name.contains(searchText) }
        }
    }
}
