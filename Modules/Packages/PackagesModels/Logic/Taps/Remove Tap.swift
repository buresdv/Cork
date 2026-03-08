//
//  Remove Tap.swift
//  Cork
//
//  Created by David Bureš on 03.09.2023.
//

import CorkShared
import CorkTerminalFunctions
import Foundation
import SwiftUI

public extension TapTracker
{
    enum UntapError: LocalizedError
    {
        case couldNotUntap(tapName: String, failureReason: String)

        public var errorDescription: String?
        {
            switch self
            {
            case .couldNotUntap(let tapName, let failureReason):
                return String(localized: "error.tap.untap.could-not-untap.tap-\(tapName).failure-reason-\(failureReason)")
            }
        }
    }

    enum FromTrackerRemovalError: LocalizedError
    {
        case noTapsWereRemoved
    }

    /// Specify what the purpose of the tap removal operation should be
    enum TapRemovalPurpose: CustomStringConvertible
    {
        /// Only remove the tap from the tracker, keep it installed
        case removeFromTracker

        /// Uninstall the tap from Homebrew, then remove it from the tracker
        case removeFromHomebrewAndTracker

        public var description: String
        {
            switch self
            {
            case .removeFromTracker:
                "Removal from tracker only"
            case .removeFromHomebrewAndTracker:
                "Removal from Homebrew and tracker"
            }
        }
    }

    /// Remove a tap, either from just the tracker, or Homebrew as well as the tracker
    /// - Parameters:
    ///   - tapToRemove: ``BrewTap`` to remove
    ///   - purpose: Whether to only remove the tap from the tracker and keep it installed, or uninstall it and then remove it
    /// - Throws:
    ///     - ``UntapError`` if the removal of the tap from Homebrew failed
    ///     - ``FromTrackerRemovalError`` if the removal of the tap from the tracker failed
    func removeTap(
        tapToRemove: BrewTap,
        purpose: TapTracker.TapRemovalPurpose
    ) async throws
    {
        appConstants.logger.info("Will start \(purpose.description) process for tap \(tapToRemove.name(withPrecision: .full), privacy: .public)")

        tapToRemove.changeBeingModifiedStatus()

        switch purpose
        {
        case .removeFromTracker:
            try self.removeTapFromTracker(tapToRemove: tapToRemove)
        case .removeFromHomebrewAndTracker:
            do
            { // This do statement has to be here so the tap doesn't get removed from the trakcer if the removal fails
                try await self.removeTapFromHomebrew(tapToRemove: tapToRemove)
                try self.removeTapFromTracker(tapToRemove: tapToRemove)
            }
            catch let tapRemovalFromTrackerError as TapTracker.FromTrackerRemovalError
            {
                /// Pass the error up the chain
                throw tapRemovalFromTrackerError
            }
            catch let tapRemovalFromHomebrewError as TapTracker.UntapError
            {
                throw tapRemovalFromHomebrewError
            }
        }
    }
}

private extension TapTracker
{
    func removeTapFromTracker(
        tapToRemove: BrewTap
    ) throws(TapTracker.FromTrackerRemovalError)
    {
        let numberOfAddedTapsBeforeRemovalAction: Int = self.numberOfAddedTaps
        
        self.addedTaps.removeAll(where: { $0 == tapToRemove })
        
        if numberOfAddedTapsBeforeRemovalAction == self.numberOfAddedTaps
        {
            throw .noTapsWereRemoved
        }
    }

    func removeTapFromHomebrew(
        tapToRemove: BrewTap
    ) async throws(TapTracker.UntapError)
    {
        let untapResult: [TerminalOutput] = await shell(appConstants.brewExecutablePath, ["untap", tapToRemove.name(withPrecision: .full)])

        if untapResult.contains("Untapped", in: .standardOutputs, .standardErrors)
        {
            appConstants.logger.info("\(TapTracker.TapRemovalPurpose.removeFromHomebrewAndTracker.description) of tap \(tapToRemove.name(withPrecision: .full), privacy: .public) was successful")
        }
        else
        {
            appConstants.logger.error("\(TapTracker.TapRemovalPurpose.removeFromHomebrewAndTracker.description, privacy: .public) of tap \(tapToRemove.name(withPrecision: .full), privacy: .public) failed")
            
            if untapResult.contains("because it contains the following installed formulae or casks")
            {
                appState.showAlert(errorToShow: .couldNotRemoveTapDueToPackagesFromItStillBeingInstalled(offendingTapProhibitingRemovalOfTap: tapToRemove.name(withPrecision: .full)))
            }
            
            throw .couldNotUntap(tapName: tapToRemove.name(withPrecision: .full), failureReason: untapResult.standardErrors.formatted(.list(type: .and)))
        }
    }
}
