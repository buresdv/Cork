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

    AppConstants.shared.logger.debug("Raw command result for health check: \(commandResult)")
    
    guard !commandResult.containsErrors else // Only go down this path if there are errors in the output
    {
        /// The output is in a massive list, as a single output. Great job Homebrew
        guard let splitOutput: [String] = commandResult.standardErrors.first?.components(separatedBy: "Warning: ") else {
            AppConstants.shared.logger.error("Failed to split [brew doctor] output, error out with the whole thing")
            
            throw .errorsThrownInStandardOutput(errors: commandResult.standardErrors)
        }
        
        AppConstants.shared.logger.debug("Standard errors for health check: \(splitOutput)")
        
        let stringsToExclude: [String] = ["Please note that these warnings are just used to help the Homebrew maintainers"]

        let errorsWithoutUselessFluff: [String] = splitOutput.filter
        { string in
            !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !string.containsAny(of: stringsToExclude)
        }
        
        let properlyFormattedErrorsWithoutUselessFluff: [String] = errorsWithoutUselessFluff.map
        { string in
            string.trimmingPrefix(" :").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        AppConstants.shared.logger.error("Brew health check had errors, removing useless fluff: \(properlyFormattedErrorsWithoutUselessFluff)")
        
        throw .errorsThrownInStandardOutput(errors: properlyFormattedErrorsWithoutUselessFluff)
    }
}
