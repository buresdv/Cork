//
//  Perform Brew HEalth Check.swift
//  Cork
//
//  Created by David Bureš on 16.02.2023.
//

import Foundation
import CorkShared
import CorkTerminalFunctions

enum HealthCheckError: LocalizedError
{
    case errorsThrownInStandardOutput

    var errorDescription: String?
    {
        switch self
        {
        case .errorsThrownInStandardOutput:
            return String(localized: "error.maintenance.health-check.standard-error-not-empty")
        }
    }
}

func performBrewHealthCheck() async throws -> TerminalOutput
{
    async let commandResult: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["doctor"])

    await print(commandResult)

    if await commandResult.standardOutput == ""
    {
        return await commandResult
    }
    else
    {
        print("Homebrew health check error: \(await commandResult.standardOutput)")
        throw HealthCheckError.errorsThrownInStandardOutput
    }
}
