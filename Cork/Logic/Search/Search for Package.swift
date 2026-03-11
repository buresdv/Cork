//
//  Search for Package.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import CorkModels
import CorkShared
import CorkTerminalFunctions
import Foundation

func searchForPackage(packageName: String, packageType: BrewPackage.PackageType) async -> [String]
{
    var finalCommandOutputs: [TerminalOutput]

    switch packageType
    {
    case .formula:
        finalCommandOutputs = await shell(AppConstants.shared.brewExecutablePath, ["search", "--formulae", packageName])

    case .cask:
        finalCommandOutputs = await shell(AppConstants.shared.brewExecutablePath, ["search", "--casks", packageName])
    }

    AppConstants.shared.logger.info("Search found these packages: \(finalCommandOutputs, privacy: .auto)")

    return finalCommandOutputs.standardOutputs
}
