//
//  Purge Brew Cache.swift
//  Cork
//
//  Created by David Bureš on 16.02.2023.
//

import Foundation

/*enum CachePurgeError: Error
{
    case standardErrorNotEmpty
}*/

func purgeBrewCache() async throws -> TerminalOutput
{
    async let commandResult = await shell("/opt/homebrew/bin/brew", ["cleanup"])

    return await commandResult
}
