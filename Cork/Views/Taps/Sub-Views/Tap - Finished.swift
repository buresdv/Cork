//
//  Tap - Finished.swift
//  Cork
//
//  Created by David Bureš on 05.12.2023.
//

import CorkModels
import CorkShared
import CorkTerminalFunctions
import FactoryKit
import SwiftUI

struct AddTapFinishedView: View
{
    @InjectedObservable(\.appState) var appState: AppState

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
                    do
                    {
                        try tapTracker.addedTaps.insert(.success(BrewTap(name: requestedTap)))
                    }
                    catch let tapTrackerAdditionError
                    {
                        appState.showAlert(errorToShow: .tapLoadingFailedDueToTapItself(localizedDescription: tapTrackerAdditionError.localizedDescription))
                    }

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
