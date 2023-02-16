//
//  Perform Brew HEalth Check.swift
//  Cork
//
//  Created by David Bureš on 16.02.2023.
//

import Foundation

enum HealthCheckError: Error
{
    case standardErrorNotEmpty
}

func performBrewHealthCheck() async throws -> TerminalOutput
{
    async let commandResult = await shell("/opt/homebrew/bin/brew", ["doctor"])
    
    if await commandResult.standardError != ""
    {
        print("ERROR: \(await commandResult.standardError)")
        throw HealthCheckError.standardErrorNotEmpty
    }
    else
    {
        return await commandResult
    }
}
