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
    case errorsThrownInStandardOutput(errors: [String])

    var errorDescription: String?
    {
        switch self
        {
        case .errorsThrownInStandardOutput:
            return String(localized: "error.maintenance.health-check.standard-error-not-empty")
        }
    }
}

func performBrewHealthCheck() async throws(HealthCheckError)
{
    let commandResult: [TerminalOutput] = await shell(AppConstants.shared.brewExecutablePath, ["doctor"])

    guard !commandResult.containsErrors else
    {
        AppConstants.shared.logger.error("Brew health check had errors: \(commandResult.standardErrors)")
        
        throw .errorsThrownInStandardOutput(errors: commandResult.standardErrors)
    }
}
