//
//  Stop Service.swift
//  Cork
//
//  Created by David Bureš on 12.05.2024.
//

import Foundation

enum ServiceStoppingError: Error
{
    case couldNotStopService(String)
}

extension ServicesTracker
{
    func stopService(_ serviceToStop: HomebrewService, servicesState: ServicesState, serviceModificationProgress: ServiceModificationProgress) async
    {
        for await output in shell(AppConstants.brewExecutablePath, ["services", "stop", serviceToStop.name])
        {
            switch output
            {
            case let .standardOutput(outputLine):
                AppConstants.logger.debug("Service stopping output: \(outputLine)")

                switch outputLine
                {
                case _ where outputLine.contains("Stopping"):
                    AppConstants.logger.debug("Stopping \(serviceToStop.name)")

                case _ where outputLine.contains("Successfully stopped"):
                    AppConstants.logger.debug("Stopped \(serviceToStop.name)")

                default:
                    AppConstants.logger.debug("Unknown step in stopping \(serviceToStop.name)")
                }

                // changeServiceStatus(serviceToStop, newStatus: .stopped)

                serviceModificationProgress.progress += 1

            case let .standardError(errorLine):
                AppConstants.logger.error("Service stopping error: \(errorLine)")

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
            AppConstants.logger.error("Could not synchronize services: \(servicesSynchronizationError.localizedDescription)")

            servicesState.showError(.couldNotSynchronizeServices(errorThrown: servicesSynchronizationError.localizedDescription))
        }
    }
}
