//
//  Load up Service Details.swift
//  Cork
//
//  Created by David Bureš on 21.03.2024.
//

import CorkShared
import CorkTerminalFunctions
import Foundation

extension HomebrewService
{
    func loadDetails() async throws(ServicesTracker.HomebrewServiceLoadingError)
    {
        AppConstants.shared.logger.debug("Will try to load up service details for service \(self.name)")

        self.isLoadingDetails = true

        defer
        {
            self.isLoadingDetails = false
        }

        let rawOutput: [TerminalOutput] = await shell(AppConstants.shared.brewExecutablePath, ["services", "info", self.name, "--json"])

        let decoder: JSONDecoder = {
            let decoder: JSONDecoder = .init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return decoder
        }()

        // MARK: - Error checking

        guard !rawOutput.containsErrors
        else
        {
            AppConstants.shared.logger.error("Failed while loading up service details: Standard Error not empty")
            throw .standardErrorNotEmpty(standardError: rawOutput.standardErrors.formatted(.list(type: .and)))
        }

        do
        {
            guard let decodableOutput: Data = rawOutput.getJsonFromOutput(failOnAnyErrorsPresent: false),
                  let decodedOutput: ServiceDetails = try decoder.decode(
                    [ServiceDetails].self,
                    from: decodableOutput
                  ).first
            else
            {
                AppConstants.shared.logger.error("Loading details for \(self.name) returned no data")
                return
            }

            print("Final details: \(decodedOutput)")

            self.details = decodedOutput
        }
        catch let parsingError
        {
            AppConstants.shared.logger.error("Parsing of service details of service \(self.name) failed: \(parsingError)")

            throw .servicesParsingFailed
        }
    }
}
