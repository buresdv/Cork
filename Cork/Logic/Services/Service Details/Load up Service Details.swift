//
//  Load up Service Details.swift
//  Cork
//
//  Created by David Bureš on 21.03.2024.
//

import Foundation

func loadUpServiceDetails(serviceToLoad: HomebrewService) async throws -> ServiceDetails
{
    AppConstants.logger.debug("Will try to load up service details for service \(serviceToLoad.name)")
    
    let serviceDetailsLoadingOutputRaw: TerminalOutput = await shell(AppConstants.brewExecutablePath, ["services", "info", serviceToLoad.name, "--json"])
    
    if !serviceDetailsLoadingOutputRaw.standardError.isEmpty
    {
        AppConstants.logger.error("Failed while loading up service details: Standard Error not empty")
        throw HomebrewServiceLoadingError.standardErrorNotEmpty
    }
    else
    {
        do
        {
            return try parseServiceDetails(rawOutput: serviceDetailsLoadingOutputRaw.standardOutput)
        } 
        catch let parsingError
        {
            AppConstants.logger.error("Parsing of service details of service \(serviceToLoad.name) failed: \(parsingError)")
            
            throw JSONError.parsingFailed
        }
    }
}
