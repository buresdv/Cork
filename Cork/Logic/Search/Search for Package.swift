//
//  Search for Package.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import Foundation
import CorkShared

func searchForPackage(packageName: String, packageType: PackageType) async throws -> [String]
{
    var finalPackageArray: [String]

    switch packageType
    {
    case .formula:
        let foundFormulae: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["search", "--formulae", packageName])

        finalPackageArray = foundFormulae.standardOutput.components(separatedBy: "\n")

    case .cask:
        let foundCasks: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["search", "--casks", packageName])

        finalPackageArray = foundCasks.standardOutput.components(separatedBy: "\n")
    }

    finalPackageArray.removeLast()

    AppConstants.shared.logger.info("Search found these packages: \(finalPackageArray, privacy: .auto)")

    return finalPackageArray
}
