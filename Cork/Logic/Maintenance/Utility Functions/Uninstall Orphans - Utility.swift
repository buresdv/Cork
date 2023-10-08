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

        print("Orphan removal output: \(orphanUninstallationOutput)")

        let numberOfUninstalledOrphansRegex: String = "(?<=Autoremoving ).*?(?= unneeded)"

        guard let numberOfRemovedOrphans = try Int(regexMatch(from: orphanUninstallationOutput.standardOutput, regex: numberOfUninstalledOrphansRegex)) else
        {
            return 0
        }

        return numberOfRemovedOrphans
    }
    catch let orphanUninstallatioError as NSError
    {
        print(orphanUninstallatioError)
        throw OrphanRemovalError.couldNotUninstallOrphans
    }
}
