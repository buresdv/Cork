//
//  Load up Services.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import CorkShared
import CorkTerminalFunctions
import Foundation

extension ServicesTracker
{
    enum HomebrewServiceLoadingError: LocalizedError
    {
        case standardErrorNotEmpty(standardError: String)
        case homebrewOutdated
        case standardErrorNotEmptyAndNoResultsInStandardOutput
        case couldNotEncodeString(String)
        case servicesParsingFailed
        case otherError(String)

        var errorDescription: String?
        {
            switch self
            {
            case .standardErrorNotEmpty(let standardError):
                return String(localized: "error.services.loading.standard-error-not-empty.\(standardError)")
            case .standardErrorNotEmptyAndNoResultsInStandardOutput:
                return String(localized: "error.services.loading.no-output")
            case .couldNotEncodeString(let string):
                return String(localized: "error.services.loading.could-not-encode-string.\(string)")
            case .servicesParsingFailed:
                return String(localized: "error.services.loading.parsing-failed")
            case .otherError(let string):
                return String(localized: "error.services.loading.other-error.\(string)")
            case .homebrewOutdated:
                return String(localized: "error.services.loading.homebrew-outdated")
            }
        }
    }

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
    func loadServices() async throws(HomebrewServiceLoadingError)
    {
        let decoder: JSONDecoder = {
            let decoder: JSONDecoder = .init()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return decoder
        }()

        let rawOutput: [TerminalOutput] = await shell(AppConstants.shared.brewExecutablePath, ["services", "list", "--json"])

        // MARK: - Error checking

        guard !rawOutput.containsErrors
        else
        {
            AppConstants.shared.logger.error("Failed while loading up services: Standard Error not empty")
            if rawOutput.standardErrors.contains("brew update")
            {
                throw .homebrewOutdated
            }
            else
            {
                throw .standardErrorNotEmpty(standardError: rawOutput.standardErrors.formatted(.list(type: .and)))
            }
        }

        do
        {
            guard !rawOutput.isEmpty && !rawOutput.contains("No services available", in: .standardErrors, .standardOutputs)
            else
            {
                AppConstants.shared.logger.info("There are no services to load")
                return
            }

            guard let decodableData: Data = rawOutput.getJsonFromOutput(failOnAnyErrorsPresent: false)
            else
            {
                AppConstants.shared.logger.error("Failed while converting services string to data")
                throw HomebrewServiceLoadingError.otherError("There was a failure encoding Services data")
            }

            /// Without this guard, the decoding throws, even if there was no error, just because the data is empty
            guard !decodableData.isEmpty
            else
            {
                return
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

            services = finalServices
        }
        catch let servicesParsingError
        {
            AppConstants.shared.logger.error("Parsing of Homebrew services failed: \(servicesParsingError)")

            throw HomebrewServiceLoadingError.servicesParsingFailed
        }
    }
}
