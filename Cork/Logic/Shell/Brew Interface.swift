//
//  Brew Interface.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import SwiftUI
import CorkShared

struct SearchResults
{
    let foundFormulae: [String]
    let foundCasks: [String]
}

func getListOfFoundPackages(searchWord: String) async -> String
{
    var parsedResponse: String?
    parsedResponse = await shell(AppConstants.shared.brewExecutablePath, ["search", searchWord]).standardOutput

    return parsedResponse!
}
