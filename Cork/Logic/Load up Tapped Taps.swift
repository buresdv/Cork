//
//  Load up Tapped Taps.swift
//  Cork
//
//  Created by David Bureš on 10.02.2023.
//

import Foundation

@MainActor
func loadUpTappedTaps() async -> [BrewTap]
{
    var finalAvailableTaps: [BrewTap] = .init()

    let contentsOfTapFolder: [URL] = getContentsOfFolder(targetFolder: AppConstants.tapPath, options: .skipsHiddenFiles)

    AppConstants.logger.debug("Contents of tap folder: \(contentsOfTapFolder)")

    for tapRepoParentURL in contentsOfTapFolder
    {
        AppConstants.logger.debug("Tap repo: \(tapRepoParentURL)")

        let contentsOfTapRepoParent: [URL] = getContentsOfFolder(targetFolder: tapRepoParentURL, options: .skipsHiddenFiles)

        for repoURL in contentsOfTapRepoParent
        {
            let repoParentComponents: [String] = repoURL.pathComponents

            let repoParentName: String = repoParentComponents.penultimate()!

            let repoNameRaw: String = repoParentComponents.last!
            let repoName = String(repoNameRaw.dropFirst(9))

            let fullTapName = "\(repoParentName)/\(repoName)"

            AppConstants.logger.info("Full tap name: \(fullTapName)")

            finalAvailableTaps.append(BrewTap(name: fullTapName))
        }
    }

    // var nonLocalBasicTaps: [BrewTap] = .init()

    let nonLocalBasicTaps = await withTaskGroup(of: BrewTap?.self)
    { taskGroup in
        if finalAvailableTaps.filter({ $0.name == "homebrew/core" }).isEmpty
        {
            AppConstants.logger.warning("Couldn't find homebrew/core in local taps")
            taskGroup.addTask
            {
                let isCoreAdded = await checkIfTapIsAdded(tapToCheck: "homebrew/core")
                if isCoreAdded
                {
                    AppConstants.logger.info("homebrew/core is added, but not in local taps")
                    return BrewTap(name: "homebrew/core")
                }
                else
                {
                    AppConstants.logger.warning("homebrew/core is not added and not in local taps")
                    return nil
                }
            }
        }
        else
        {
            AppConstants.logger.info("Found homebrew/core in local taps")
        }

        if finalAvailableTaps.filter({ $0.name == "homebrew/cask" }).isEmpty
        {
            AppConstants.logger.warning("Couldn't find homebrew/cask in local taps")
            taskGroup.addTask
            {
                let isCaskAdded = await checkIfTapIsAdded(tapToCheck: "homebrew/cask")
                if isCaskAdded
                {
                    return BrewTap(name: "homebrew/cask")
                }
                else
                {
                    AppConstants.logger.warning("homebrew/cask is not added and not in local taps")
                    return nil
                }
            }
        }
        else
        {
            AppConstants.logger.info("Found homebrew/cask in local taps")
        }

        var nonLocalBasicTapsInternal: [BrewTap] = .init()

        for await tap in taskGroup
        {
            if let tap = tap
            {
                nonLocalBasicTapsInternal.append(tap)
            }
        }

        return nonLocalBasicTapsInternal
    }

    finalAvailableTaps.append(contentsOf: nonLocalBasicTaps)

    return finalAvailableTaps
}

private func checkIfTapIsAdded(tapToCheck: String) async -> Bool
{
    return true
}
