//
//  Load up Service Details.swift
//  Cork
//
//  Created by David Bureš on 21.03.2024.
//

import Foundation
import CorkShared
import CorkTerminalFunctions

extension HomebrewService
{
    @MainActor
    func loadDetails() async throws(ServicesTracker.HomebrewServiceLoadingError) -> ServiceDetails?
    {
        AppConstants.shared.logger.debug("Will try to load up service details for service \(name)")

        let rawOutput: [TerminalOutput] = await shell(AppConstants.shared.brewExecutablePath, ["services", "info", name, "--json"])

        let decoder: JSONDecoder = {
            let decoder: JSONDecoder = .init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return decoder
        }()

        // MARK: - Error checking

        guard !rawOutput.containsErrors else
        {
            AppConstants.shared.logger.error("Failed while loading up service details: Standard Error not empty")
            throw .standardErrorNotEmpty(standardError: rawOutput.standardErrors.formatted(.list(type: .and)))
        }

        do
        {
            guard let decodableOutput: Data = rawOutput.getJsonFromOutput(failOnAnyErrorsPresent: false)
            else
            {
                return nil
            }

            guard let decodedOutput: ServiceDetails = try decoder.decode([ServiceDetails].self, from: decodableOutput).first
            else
            {
                return nil
            }

            return decodedOutput
        }
        catch let parsingError
        {
            AppConstants.shared.logger.error("Parsing of service details of service \(self.name) failed: \(parsingError)")

            throw .servicesParsingFailed
        }
    }
}
