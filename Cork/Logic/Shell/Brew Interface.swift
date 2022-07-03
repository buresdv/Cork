//
//  Brew Interface.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

enum BrewCommands {
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

struct SearchResults {
    let foundFormulae: [String]
    let foundCasks: [String]
}

func getListOfFoundPackages(searchWord: String) -> String {
    var parsedResponse: String?
    Task {
        parsedResponse = await shell("/opt/homebrew/bin/brew", ["search", searchWord])!
    }
    
    return parsedResponse!
}
