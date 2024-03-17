//
//  Uninstall Orphans - Utility.swift
//  Cork
//
//  Created by David Bureš on 08.10.2023.
//

import Foundation

enum OrphanRemovalError: Error
{
    case couldNotUninstallOrphans, couldNotGetNumberOfUninstalledOrphans
}

/// Returns the number of uninstaller orphans
func uninstallOrphansUtility() async throws -> Int
{
    do
    {

        let orphanUninstallationOutput = try await uninstallOrphanedPackages()

        AppConstants.logger.debug("Orphan removal output:\nStandard output: \(orphanUninstallationOutput.standardOutput, privacy: .public)\nStandard error: \(orphanUninstallationOutput.standardError, privacy: .public)")

        if orphanUninstallationOutput.standardError.isEmpty && orphanUninstallationOutput.standardOutput.isEmpty
        {
            AppConstants.logger.info("No orphans found")
            return 0
        }
        else
        {
            let numberOfUninstalledOrphansRegex: String = "(?<=Autoremoving ).*?(?= unneeded)"

            guard let numberOfRemovedOrphans = try Int(regexMatch(from: orphanUninstallationOutput.standardOutput, regex: numberOfUninstalledOrphansRegex)) else
            {
                throw OrphanRemovalError.couldNotGetNumberOfUninstalledOrphans
            }

            return numberOfRemovedOrphans
        }
    }
    catch let orphanUninstallatioError as NSError
    {
        AppConstants.logger.error("Orphan uninstallation error: \(orphanUninstallatioError, privacy: .public)")
        throw OrphanRemovalError.couldNotUninstallOrphans
    }
}
