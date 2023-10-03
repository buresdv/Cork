//
//  Remove Tap.swift
//  Cork
//
//  Created by David Bureš on 03.09.2023.
//

import Foundation
import SwiftUI

enum UntapError: Error
{
    case couldNotUntap
}

@MainActor
func removeTap(name: String, availableTaps: AvailableTaps, appState: AppState, shouldApplyUninstallSpinnerToRelevantItemInSidebar: Bool = false) async throws
{
    var indexToReplaceGlobal: Int?

    /// Store the old navigation selection to see if it got updated in the middle of switching
    let oldNavigationSelectionID: UUID? = appState.navigationSelection

    if shouldApplyUninstallSpinnerToRelevantItemInSidebar
    {
        availableTaps.addedTaps = Set(availableTaps.addedTaps.map
        { tap in
            var copyTap = tap
            if copyTap.name == name
            {
                copyTap.changeBeingModifiedStatus()
            }
            return copyTap
        })
    }
    else
    {
        appState.isShowingUninstallationProgressView = true
    }

    let untapResult = await shell(AppConstants.brewExecutablePath.absoluteString, ["untap", name]).standardError
    print("Untapping result: \(untapResult)")

    defer
    {
        appState.isShowingUninstallationProgressView = false
    }

    if untapResult.contains("Untapped")
    {
        print("Untapping was successful")

        availableTaps.removeTapFromTrackerByName(name)

        if appState.navigationSelection != nil
        {
            /// Switch to the status page only if the user didn't open another details window in the middle of the tap removal process
            if oldNavigationSelectionID == appState.navigationSelection
            {
                appState.navigationSelection = nil
            }
        }
    }
    else
    {
        print("Untapping failed")

        if untapResult.contains("because it contains the following installed formulae or casks")
        {
            appState.offendingTapProhibitingRemovalOfTap = name
            appState.fatalAlertType = .couldNotRemoveTapDueToPackagesFromItStillBeingInstalled
            appState.isShowingFatalError = true
        }

        availableTaps.addedTaps = Set(availableTaps.addedTaps.map
        { tap in
            var copyTap = tap
            if copyTap.name == name, copyTap.isBeingModified == true
            {
                copyTap.changeBeingModifiedStatus()
            }
            return copyTap
        })

        throw UntapError.couldNotUntap
    }
}
