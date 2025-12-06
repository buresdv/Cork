//
//  Purge Brew Cache.swift
//  Cork
//
//  Created by David Bureš on 16.02.2023.
//

import Foundation
import CorkShared
import CorkTerminalFunctions

/* enum CachePurgeError: Error
 {
     case standardErrorNotEmpty
 } */

func purgeBrewCache() async throws -> TerminalOutput
{
    async let commandResult: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["cleanup"])

    return await commandResult
}
