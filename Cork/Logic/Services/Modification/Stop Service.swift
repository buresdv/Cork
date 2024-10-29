//
//  Stop Service.swift
//  Cork
//
//  Created by David Bureš on 12.05.2024.
//

import Foundation
import CorkShared

enum ServiceStoppingError: LocalizedError
{
    case couldNotStopService(String)

    var errorDescription: String?
    {
        switch self
        {
        case .couldNotStopService(let string):
            return String(localized: "error.services.stopping.could-not-stop-service.\(string)")
        }
    }
}

extension ServicesTracker
{
    func stopService(_ serviceToStop: HomebrewService, servicesState: ServicesState, serviceModificationProgress: ServiceModificationProgress) async
    {
        for await output in shell(AppConstants.shared.brewExecutablePath, ["services", "stop", serviceToStop.name])
        {
            switch output
            {
            case .standardOutput(let outputLine):
                AppConstants.shared.logger.debug("Service stopping output: \(outputLine)")

                switch outputLine
                {
                case _ where outputLine.contains("Stopping"):
                    AppConstants.shared.logger.debug("Stopping \(serviceToStop.name)")

                case _ where outputLine.contains("Successfully stopped"):
                    AppConstants.shared.logger.debug("Stopped \(serviceToStop.name)")

                default:
                    AppConstants.shared.logger.debug("Unknown step in stopping \(serviceToStop.name)")
                }

                serviceModificationProgress.progress += 1

            case .standardError(let errorLine):
                AppConstants.shared.logger.error("Service stopping error: \(errorLine)")

                servicesState.showError(.couldNotStopService(offendingService: serviceToStop.name, errorThrown: errorLine))
            }
        }

        do
        {
            serviceModificationProgress.progress = 5.0

            try await synchronizeServices(preserveIDs: true)
        }
        catch let servicesSynchronizationError
        {
            AppConstants.shared.logger.error("Could not synchronize services: \(servicesSynchronizationError.localizedDescription)")

            servicesState.showError(.couldNotSynchronizeServices(errorThrown: servicesSynchronizationError.localizedDescription))
        }
    }
}
