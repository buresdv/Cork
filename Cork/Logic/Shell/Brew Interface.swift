//
//  Brew Interface.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import SwiftUI

struct SearchResults
{
    let foundFormulae: [String]
    let foundCasks: [String]
}

func getListOfFoundPackages(searchWord: String) async -> String
{
    var parsedResponse: String?
    parsedResponse = await shell("/opt/homebrew/bin/brew", ["search", searchWord]).standardOutput

    return parsedResponse!
}

func getListOfUpgradeablePackages() async -> [BrewPackage]
{
    var finalOutdatedPackages = [BrewPackage]()
    
    let outdatedPackagesRaw: String = await shell("/opt/homebrew/bin/brew", ["outdated"]).standardOutput
    
    print("Outdated packages output: \(outdatedPackagesRaw)")
    
    let outdatedPackages = outdatedPackagesRaw.components(separatedBy: "\n")
    
    for package in outdatedPackages {
        finalOutdatedPackages.append(BrewPackage(name: package, isCask: false, installedOn: nil, versions: [""], sizeInBytes: nil))
    }
    
    finalOutdatedPackages.removeLast()
    
    return finalOutdatedPackages
}

func addTap(name: String) async -> String
{
    let tapResult = await shell("/opt/homebrew/bin/brew", ["tap", name]).standardError
    
    print("Tapping result: \(tapResult)")
    
    return tapResult
}

enum UntapError: Error
{
    case couldNotUntap
}

func removeTap(name: String, availableTaps: AvailableTaps, appState: AppState) async throws -> Void
{
    let untapResult = await shell("/opt/homebrew/bin/brew", ["untap", name]).standardError
    print("Untapping result: \(untapResult)")
    
    if untapResult.contains("Untapped")
    {
        print("Untapping was successful")
        DispatchQueue.main.async {
            withAnimation {
                availableTaps.addedTaps.removeAll(where: { $0.name == name })
            }
        }
    }
    else
    {
        print("Untapping failed")
        
        appState.isShowingRemoveTapFailedAlert = true
        
        throw UntapError.couldNotUntap
    }
}
