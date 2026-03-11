//
//  Uninstall Orphans - Utility.swift
//  Cork
//
//  Created by David Bureš on 08.10.2023.
//

import Foundation
import CorkShared
import CorkTerminalFunctions

enum OrphanRemovalError: LocalizedError
{
    case couldNotUninstallOrphans(output: String), couldNotGetNumberOfUninstalledOrphans

    var errorDescription: String?
    {
        switch self
        {
        case .couldNotUninstallOrphans(let output):
            return String(localized: "error.maintenance.orphan-removal.could-not-uninstall-orphans.\(output)")
        case .couldNotGetNumberOfUninstalledOrphans:
            return String(localized: "error.maintenance.orphan-removal.could-not-get-number-of-uninstalled-orphans")
        }
    }
}

/// Returns the number of uninstaller orphans
func uninstallOrphansUtility() async throws -> Int
{
    do
    {
        let orphanUninstallationOutput: [TerminalOutput] = try await uninstallOrphanedPackages()

        AppConstants.shared.logger.debug("Orphan removal output:\nStandard output: \(orphanUninstallationOutput.standardOutputs, privacy: .public)\nStandard error: \(orphanUninstallationOutput.standardErrors, privacy: .public)")

        if orphanUninstallationOutput.standardErrors.isEmpty && orphanUninstallationOutput.standardOutputs.isEmpty
        {
            AppConstants.shared.logger.info("No orphans found")
            return 0
        }
        else
        {
            guard let numberOfRemovedOrphans: Int = try Int(orphanUninstallationOutput.standardOutputs.joined().regexMatch("(?<=Autoremoving ).*?(?= unneeded)"))
            else
            {
                throw OrphanRemovalError.couldNotGetNumberOfUninstalledOrphans
            }

            return numberOfRemovedOrphans
        }
    }
    catch let orphanUninstallatioError
    {
        AppConstants.shared.logger.error("Orphan uninstallation error: \(orphanUninstallatioError, privacy: .public)")
        throw OrphanRemovalError.couldNotUninstallOrphans(output: orphanUninstallatioError.localizedDescription)
    }
}
