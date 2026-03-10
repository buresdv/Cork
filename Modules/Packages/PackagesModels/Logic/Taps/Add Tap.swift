//
//  Add Tap.swift
//  Cork
//
//  Created by David Bureš on 03.09.2023.
//

import Foundation
import CorkShared
import CorkTerminalFunctions

public func addTap(name: String, forcedRepoAddress: String? = nil) async -> String
{
    var tapResult: String

    if let forcedRepoAddress
    {
        tapResult = await shell(AppConstants.shared.brewExecutablePath, ["tap", name, forcedRepoAddress]).standardErrors.joined()
    }
    else
    {
        tapResult = await shell(AppConstants.shared.brewExecutablePath, ["tap", name]).standardErrors.joined()
    }

    AppConstants.shared.logger.debug("Tapping result: \(tapResult, privacy: .public)")

    return tapResult
}
