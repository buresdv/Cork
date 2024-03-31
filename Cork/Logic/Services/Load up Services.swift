//
//  Load up Services.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import Foundation

enum HomebrewServiceLoadingError: Error
{
    case standardErrorNotEmpty, standardErrorNotEmptyAndNoResultsInStandardOutput, servicesParsingFailed
}

@MainActor
func loadUpServices(servicesState: ServicesState) async throws -> Set<HomebrewService>
{
    AppConstants.logger.debug("Will try to load up services")
    
    defer
    {
        servicesState.isLoadingServices = false
    }
    
    let serviceLoadingResultRaw: TerminalOutput = await shell(AppConstants.brewExecutablePath, ["services", "list", "--json"])
    
    if !serviceLoadingResultRaw.standardError.isEmpty
    {
        AppConstants.logger.error("Failed while loading up services: Standard Error not empty")
        throw HomebrewServiceLoadingError.standardErrorNotEmpty
    }
    else
    {
        do
        {
            AppConstants.logger.log("Will work with this services output: \(serviceLoadingResultRaw.standardOutput)")
            
            let parsedServices: Set<HomebrewService> = try parseServices(rawOutput: serviceLoadingResultRaw.standardOutput)
            
            return parsedServices
        }
        catch let parsingError
        {
            AppConstants.logger.error("Parsing of Homebrew services failed: \(parsingError)")
            
            throw JSONError.parsingFailed
        }
    }
}
