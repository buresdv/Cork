//
//  Load up Service Details.swift
//  Cork
//
//  Created by David Bureš on 21.03.2024.
//

import Foundation

extension HomebrewService
{    
    @MainActor
    func loadDetails() async throws -> ServiceDetails?
    {
        AppConstants.logger.debug("Will try to load up service details for service \(self.name)")
        
        let rawOutput: TerminalOutput = await shell(AppConstants.brewExecutablePath, ["services", "info", self.name, "--json"])
        
        let decoder: JSONDecoder =
        {
            let decoder: JSONDecoder = .init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return decoder
        }()
        
        // MARK: - Error checking
        if !rawOutput.standardError.isEmpty
        {
            AppConstants.logger.error("Failed while loading up service details: Standard Error not empty")
            throw HomebrewServiceLoadingError.standardErrorNotEmpty(standardError: rawOutput.standardError)
        }
        
        do
        {
            guard let decodableOutput: Data = rawOutput.standardOutput.data(using: .utf8, allowLossyConversion: false) else
            {
                return nil
            }
            
            guard let decodedOutput: ServiceDetails = try decoder.decode([ServiceDetails].self, from: decodableOutput).first else
            {
                return nil
            }
            
            return decodedOutput
        }
        catch let parsingError
        {
            AppConstants.logger.error("Parsing of service details of service \(self.name) failed: \(parsingError)")
            
            throw HomebrewServiceLoadingError.servicesParsingFailed
        }
    }
}
