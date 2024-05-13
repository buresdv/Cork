//
//  Start Service.swift
//  Cork
//
//  Created by David Bureš on 12.05.2024.
//

import Foundation

extension ServicesTracker
{
    func startService(_ serviceToStart: HomebrewService, servicesState: ServicesState, serviceModificationProgress: ServiceModificationProgress) async
    {
        for await output in shell(AppConstants.brewExecutablePath, ["services", "start", serviceToStart.name])
        {
            switch output
            {
            case let .standardOutput(outputLine):
                AppConstants.logger.debug("Services startup output line: \(outputLine)")
                switch outputLine
                {
                case _ where outputLine.contains("Successfully started"):
                    AppConstants.logger.debug("Started \(serviceToStart.name) with no problems")
                default:
                    AppConstants.logger.debug("Service started, but there were some problems")
                }

                serviceModificationProgress.progress += 1

            // self.changeServiceStatus(serviceToStart, newStatus: .started)
            case let .standardError(errorLine):
                switch errorLine
                {
                case _ where errorLine.contains("must be run as root"):
                    AppConstants.logger.debug("Service must be run as root")

                    servicesState.showError(.couldNotStartService(offendingService: serviceToStart.name, errorThrown: String(localized: "services.error.must-be-run-as-root")))

                default:
                    AppConstants.logger.warning("Could not start service: \(errorLine)")

                    servicesState.showError(.couldNotStartService(offendingService: serviceToStart.name, errorThrown: errorLine))
                }

                // self.changeServiceStatus(serviceToStart, newStatus: .error)
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
