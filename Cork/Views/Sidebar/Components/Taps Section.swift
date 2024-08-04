//
//  Taps Section.swift
//  Cork
//
//  Created by David Bureš on 03.06.2023.
//

import SwiftUI

struct TapsSection: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var availableTaps: AvailableTaps

    let searchText: String

    var body: some View
    {
        Section("sidebar.section.added-taps")
        {
            if availableTaps.addedTaps.count != 0
            {
                ForEach(displayedTaps)
                { tap in
                    NavigationLink
                    {
                        TapDetailView(tap: tap)
                            .id(tap.id)
                    } label: {
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
                        Button
                        {
                            Task(priority: .userInitiated)
                            {
                                AppConstants.logger.debug("Would remove \(tap.name, privacy: .public)")
                                
                                try await availableTaps.removeTap(
                                    name: tap.name,
                                    appState: appState,
                                    shouldApplyUninstallSpinnerToRelevantItemInSidebar: true)
                            }
                        } label: {
                            Text("sidebar.section.added-taps.contextmenu.remove-\(tap.name)")
                        }
                    }
                }
            }
            else
            {
                ProgressView()
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
