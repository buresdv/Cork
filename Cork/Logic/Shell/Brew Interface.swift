//
//  Brew Interface.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

enum BrewCommands
{
    case search, info, install, delete
}

/*
 func executeBrewCommand(commandType: BrewCommands, argument: String? = nil) -> String {
     switch commandType {
     case .search:
         <#code#>
     case .info:
         <#code#>
     case .install:
         <#code#>
     case .delete:
         <#code#>
     }
 }
 */

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
    
    let outdatedPackages = outdatedPackagesRaw.components(separatedBy: "\n")
    
    for package in outdatedPackages {
        finalOutdatedPackages.append(BrewPackage(name: package, installedOn: nil, versions: [""], sizeInBytes: nil))
    }
    
    finalOutdatedPackages.removeLast()
    
    return finalOutdatedPackages
}

func tapAtap(tapName: String) async -> String
{
    let tapResult = await shell("/opt/homebrew/bin/brew", ["tap", tapName]).standardError
    
    print("Tapping result: \(tapResult)")
    
    return tapResult
}
