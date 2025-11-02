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
        tapResult = await shell(AppConstants.shared.brewExecutablePath, ["tap", name, forcedRepoAddress]).standardError
    }
    else
    {
        tapResult = await shell(AppConstants.shared.brewExecutablePath, ["tap", name]).standardError
    }

    AppConstants.shared.logger.debug("Tapping result: \(tapResult, privacy: .public)")

    return tapResult
}
