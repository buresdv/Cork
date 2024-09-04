//
//  Uninstall Orphans - Utility.swift
//  Cork
//
//  Created by David Bureš on 08.10.2023.
//

import Foundation
import CorkShared

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
        let orphanUninstallationOutput: TerminalOutput = try await uninstallOrphanedPackages()

        AppConstants.logger.debug("Orphan removal output:\nStandard output: \(orphanUninstallationOutput.standardOutput, privacy: .public)\nStandard error: \(orphanUninstallationOutput.standardError, privacy: .public)")

        if orphanUninstallationOutput.standardError.isEmpty && orphanUninstallationOutput.standardOutput.isEmpty
        {
            AppConstants.logger.info("No orphans found")
            return 0
        }
        else
        {
            guard let numberOfRemovedOrphans: Int = try Int(orphanUninstallationOutput.standardOutput.regexMatch("(?<=Autoremoving ).*?(?= unneeded)"))
            else
            {
                throw OrphanRemovalError.couldNotGetNumberOfUninstalledOrphans
            }

            return numberOfRemovedOrphans
        }
    }
    catch let orphanUninstallatioError
    {
        AppConstants.logger.error("Orphan uninstallation error: \(orphanUninstallatioError, privacy: .public)")
        throw OrphanRemovalError.couldNotUninstallOrphans(output: orphanUninstallatioError.localizedDescription)
    }
}
