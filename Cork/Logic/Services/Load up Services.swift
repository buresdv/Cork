//
//  Load up Services.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import Foundation

enum HomebrewServiceLoadingError: Error
{
    case standardErrorNotEmpty, standardErrorNotEmptyAndNoResultsInStandardOutput, couldNotEncodeString(String), servicesParsingFailed, otherError(String)
}

extension ServicesTracker
{
    fileprivate struct ServiceCommandOutput: Codable
    {
        /// Name of the service
        let name: String
        
        /// Current status of the service
        let status: ServiceStatus
        
        /// The executor user
        let user: String?
        
        /// Address of the service
        let file: URL
        
        /// Exit code of the service
        let exitCode: Int?
    }
    
    
    /// Load services into the service tracker
    func loadServices() async throws
    {
        let decoder: JSONDecoder =
        {
            let decoder: JSONDecoder = .init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return decoder
        }()
        
        let rawOutput: TerminalOutput = await shell(AppConstants.brewExecutablePath, ["services", "list", "--json"])
        
        // MARK: - Error checking
        if !rawOutput.standardError.isEmpty
        {
            AppConstants.logger.error("Failed while loading up services: Standard Error not empty")
            throw HomebrewServiceLoadingError.standardErrorNotEmpty
        }
        
        do
        {
            guard let decodableData: Data = rawOutput.standardOutput.data(using: .utf8, allowLossyConversion: false) else
            {
                AppConstants.logger.error("Failed while converting services string to data")
                throw HomebrewServiceLoadingError.otherError("There was a failure encoding Services data")
            }
            
            let rawDecodedServicesData: [ServiceCommandOutput] = try decoder.decode([ServiceCommandOutput].self, from: decodableData)
            
            var finalServices: Set<HomebrewService> = .init()
            
            for decodedService in rawDecodedServicesData
            {
                finalServices.insert(.init(
                    name: decodedService.name,
                    status: decodedService.status,
                    user: decodedService.user,
                    location: decodedService.file,
                    exitCode: decodedService.exitCode
                ))
            }
            
            self.services = finalServices
        }
        catch let servicesParsingError
        {
            AppConstants.logger.error("Parsing of Homebrew services failed: \(servicesParsingError)")
            
            throw JSONError.parsingFailed(nil)
        }
    }
}
