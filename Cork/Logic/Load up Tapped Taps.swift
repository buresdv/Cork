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

    print("Contents of tap folder: \(contentsOfTapFolder)")
    
    if !contentsOfTapFolder.isEmpty // Check if there are any taps available
    { // If the folder is not empty, it means we can load from disk
        for tapRepoParentURL in contentsOfTapFolder
        {

            print("Tap repo: \(tapRepoParentURL)")

            let contentsOfTapRepoParent: [URL] = getContentsOfFolder(targetFolder: tapRepoParentURL, options: .skipsHiddenFiles)

            for repoURL in contentsOfTapRepoParent {

                let repoParentComponents: [String] = repoURL.pathComponents

                let repoParentName: String = repoParentComponents.penultimate()!

                let repoNameRaw: String = repoParentComponents.last!
                let repoName: String = String(repoNameRaw.dropFirst(9))

                let fullTapName: String = "\(repoParentName)/\(repoName)"

                print("Full tap name: \(fullTapName)")

                finalAvailableTaps.append(BrewTap(name: fullTapName))
            }
        }
    }
    else
    { // If the folder is empty, it means homebrew/core and homebrew/cask are not local and we have to load from Homebrew
        let tapDiscoveryCommandResult: String = await shell(AppConstants.brewExecutablePath.absoluteString, ["tap"]).standardOutput

        let tapsArray = tapDiscoveryCommandResult.components(separatedBy: ",").filter({ !$0.isEmpty })

        for tap in tapsArray
        {
            finalAvailableTaps.append(BrewTap(name: tap))
        }
    }
    
    return finalAvailableTaps
}
