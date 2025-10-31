//
//  Purge Cache Utility.swift
//  Cork
//
//  Created by David Bureš on 08.10.2023.
//

import Foundation
import CorkShared
import CorkTerminalFunctions

enum HomebrewCachePurgeError: LocalizedError
{
    case purgingCommandFailed, regexMatchingCouldNotMatchAnything

    var errorDescription: String?
    {
        switch self
        {
        case .purgingCommandFailed:
            return String(localized: "error.maintenance.cache-purging.command-failed")
        case .regexMatchingCouldNotMatchAnything:
            return String(localized: "error.regex.nothing-matched")
        }
    }
}

/// Returns the packages that held back cahce purging. Returns an empty array if all purging was successful
func purgeHomebrewCacheUtility() async throws -> [String]
{
    do
    {
        let cachePurgeOutput: TerminalOutput = try await purgeBrewCache()

        AppConstants.shared.logger.debug("Cache purge output:\nStandard output: \(cachePurgeOutput.standardOutput, privacy: .auto)\nStandard error: \(cachePurgeOutput.standardError, privacy: .public)")

        var packagesHoldingBackCachePurgeTracker: [String] = .init()

        if cachePurgeOutput.standardError.contains("Warning: Skipping")
        { // Here, we'll write out all the packages that are blocking updating
            var packagesHoldingBackCachePurgeInitialArray: [String] = cachePurgeOutput.standardError.components(separatedBy: "Warning:") // The output has these packages in one giant list. Split them into an array so we can iterate over them and extract their names
            // I can't just try to regex-match on the raw output, because it will only match the first package in that case

            packagesHoldingBackCachePurgeInitialArray.removeFirst() // The first element in this array is "" for some reason, remove that so we save some resources

            for blockingPackageRaw in packagesHoldingBackCachePurgeInitialArray
            {
                AppConstants.shared.logger.log("Blocking package: \(blockingPackageRaw, privacy: .public)")

                guard let packageHoldingBackCachePurgeName = try? blockingPackageRaw.regexMatch("(?<=Skipping ).*?(?=:)")
                else
                {
                    throw HomebrewCachePurgeError.regexMatchingCouldNotMatchAnything
                }

                packagesHoldingBackCachePurgeTracker.append(packageHoldingBackCachePurgeName)
            }

            AppConstants.shared.logger.info("These packages are holding back cache purge: \(packagesHoldingBackCachePurgeTracker, privacy: .public)")
        }

        return packagesHoldingBackCachePurgeTracker
    }
    catch let purgingCommandError
    {
        AppConstants.shared.logger.error("Homebrew cache purging command failed: \(purgingCommandError, privacy: .public)")
        throw HomebrewCachePurgeError.purgingCommandFailed
    }
}
