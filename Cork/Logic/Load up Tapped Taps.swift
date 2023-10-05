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
    
    return finalAvailableTaps
}
