//
//  Remove Tap.swift
//  Cork
//
//  Created by David Bureš on 03.09.2023.
//

import Foundation
import SwiftUI
import CorkShared

enum UntapError: LocalizedError
{
    case couldNotUntap(tapName: String, failureReason: String)

    var errorDescription: String?
    {
        switch self
        {
        case .couldNotUntap(let tapName, let failureReason):
            return String(localized: "error.tap.untap.could-not-untap.tap-\(tapName).failure-reason-\(failureReason)")
        }
    }
}

@MainActor
func removeTap(name: String, tapTracker: TapTracker, appState: AppState, shouldApplyUninstallSpinnerToRelevantItemInSidebar: Bool = false) async throws
{
    var indexToReplaceGlobal: Int?

    /// Store the old navigation selection to see if it got updated in the middle of switching
    let oldNavigationTargetId: UUID? = appState.navigationTargetId

    if shouldApplyUninstallSpinnerToRelevantItemInSidebar
    {
        if let indexToReplace = tapTracker.addedTaps.firstIndex(where: { $0.name == name })
        {
            tapTracker.addedTaps[indexToReplace].changeBeingModifiedStatus()

            indexToReplaceGlobal = indexToReplace
        }
    }
    else
    {
        appState.isShowingUninstallationProgressView = true
    }

    let untapResult: String = await shell(AppConstants.shared.brewExecutablePath, ["untap", name]).standardError
    AppConstants.shared.logger.debug("Untapping result: \(untapResult)")

    defer
    {
        appState.isShowingUninstallationProgressView = false
    }

    if untapResult.contains("Untapped")
    {
        AppConstants.shared.logger.info("Untapping was successful")
        DispatchQueue.main.async
        {
            withAnimation
            {
                tapTracker.addedTaps.removeAll(where: { $0.name == name })
            }
        }

        if appState.navigationTargetId != nil
        {
            /// Switch to the status page only if the user didn't open another details window in the middle of the tap removal process
            if oldNavigationTargetId == appState.navigationTargetId
            {
                appState.navigationTargetId = nil
            }
        }
    }
    else
    {
        AppConstants.shared.logger.warning("Untapping failed")

        if untapResult.contains("because it contains the following installed formulae or casks")
        {
            appState.showAlert(errorToShow: .couldNotRemoveTapDueToPackagesFromItStillBeingInstalled(offendingTapProhibitingRemovalOfTap: name))
        }

        if let indexToReplaceGlobal
        {
            tapTracker.addedTaps[indexToReplaceGlobal].changeBeingModifiedStatus()
        }
        else
        {
            AppConstants.shared.logger.warning("Could not get index for that tap. Will loop over all of them")
            
            for index in tapTracker.addedTaps.indices
            {
                if tapTracker.addedTaps[index].isBeingModified
                {
                    tapTracker.addedTaps[index].isBeingModified = false
                }
            }
        }

        throw UntapError.couldNotUntap(tapName: name, failureReason: untapResult)
    }
}
