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
        
        let stringsToExclude: [String] = ["Please note that these warnings are just used to help the Homebrew maintainers"]

        let errorsWithoutUselessFluff: [String] = commandResult.standardErrors.filter
        { string in
            !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && stringsToExclude.allSatisfy { !string.contains($0) }
        }
        
        AppConstants.shared.logger.error("Brew health check had errors, removing useless fluff: \(errorsWithoutUselessFluff)")
        
        throw .errorsThrownInStandardOutput(errors: errorsWithoutUselessFluff)
    }
}
