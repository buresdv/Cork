//
//  Tap - Finished.swift
//  Cork
//
//  Created by David Bureš on 05.12.2023.
//

import SwiftUI
import CorkShared
import CorkModels
import CorkTerminalFunctions

struct AddTapFinishedView: View
{
    @Environment(TapTracker.self) var tapTracker: TapTracker

    let requestedTap: String

    var body: some View
    {
        ComplexWithIcon(systemName: "checkmark.seal")
        {
            DisappearableSheet
            {
                HeadlineWithSubheadline(
                    headline: "add-tap.complete-\(requestedTap)",
                    subheadline: "add-tap.complete.description",
                    alignment: .leading
                )
                .fixedSize(horizontal: true, vertical: true)
                .onAppear
                {
                    withAnimation
                    {
                        tapTracker.addedTaps.prepend(BrewTap(name: requestedTap))
                    }

                    /// Remove that one element of the array that's empty for some reason
                    tapTracker.addedTaps.removeAll(where: { $0.name == "" })

                    AppConstants.shared.logger.info("Available taps: \(tapTracker.addedTaps, privacy: .public)")
                }
                .task
                { // Force-load the packages from the new tap
                    AppConstants.shared.logger.info("Will update packages")
                    await shell(AppConstants.shared.brewExecutablePath, ["update"])
                }
            }
        }
    }
}
