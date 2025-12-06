//
//  Taps Section.swift
//  Cork
//
//  Created by David Bureš on 03.06.2023.
//

import CorkShared
import SwiftUI
import ButtonKit
import CorkModels

struct TapsSection: View
{
    @Environment(AppState.self) var appState: AppState
    @Environment(TapTracker.self) var tapTracker: TapTracker

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
                        NavigationLink(value: AppState.NavigationManager.DetailDestination.tap(tap: tap))
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

                                try await removeTap(name: tap.name, tapTracker: tapTracker, appState: appState, shouldApplyUninstallSpinnerToRelevantItemInSidebar: true)
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
            return tapTracker.addedTaps
        }
        else
        {
            return tapTracker.addedTaps.filter { $0.name.contains(searchText) }
        }
    }
}
