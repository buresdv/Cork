//
//  Purge Cache Utility.swift
//  Cork
//
//  Created by David Bureš on 08.10.2023.
//

import Foundation

enum HomebrewCachePurgeError: Error
{
    case purgingCommandFailed, regexMatchingCouldNotMatchAnything
}

/// Returns the packages that held back cahce purging. Returns an empty array if all purging was successful
func purgeHomebrewCacheUtility() async throws -> [String]
{
    do
    {
        let cachePurgeOutput = try await purgeBrewCache()

        AppConstants.logger.debug("Cache purge output:\nStandard output: \(cachePurgeOutput.standardOutput, privacy: .auto)\nStandard error: \(cachePurgeOutput.standardError, privacy: .public)")

        var packagesHoldingBackCachePurgeTracker: [String] = .init()

        if cachePurgeOutput.standardError.contains("Warning: Skipping")
        { // Here, we'll write out all the packages that are blocking updating
            var packagesHoldingBackCachePurgeInitialArray = cachePurgeOutput.standardError.components(separatedBy: "Warning:") // The output has these packages in one giant list. Split them into an array so we can iterate over them and extract their names
            // I can't just try to regex-match on the raw output, because it will only match the first package in that case

            packagesHoldingBackCachePurgeInitialArray.removeFirst() // The first element in this array is "" for some reason, remove that so we save some resources

            for blockingPackageRaw in packagesHoldingBackCachePurgeInitialArray
            {
                AppConstants.logger.log("Blocking package: \(blockingPackageRaw, privacy: .public)")

                let packageHoldingBackCachePurgeNameRegex = "(?<=Skipping ).*?(?=:)"

                guard let packageHoldingBackCachePurgeName = try? regexMatch(from: blockingPackageRaw, regex: packageHoldingBackCachePurgeNameRegex) else
                {
                    throw HomebrewCachePurgeError.regexMatchingCouldNotMatchAnything
                }

                packagesHoldingBackCachePurgeTracker.append(packageHoldingBackCachePurgeName)
            }

            AppConstants.logger.info("These packages are holding back cache purge: \(packagesHoldingBackCachePurgeTracker, privacy: .public)")
        }

        return packagesHoldingBackCachePurgeTracker
    }
    catch let purgingCommandError
    {
        AppConstants.logger.error("Homebrew cache purging command failed: \(purgingCommandError, privacy: .public)")
        throw HomebrewCachePurgeError.purgingCommandFailed
    }
}
