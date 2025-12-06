//
//  Start Service.swift
//  Cork
//
//  Created by David Bureš on 12.05.2024.
//

import Foundation
import CorkShared
import CorkTerminalFunctions

extension ServicesTracker
{
    func startService(_ serviceToStart: HomebrewService, servicesState: ServicesState, serviceModificationProgress: ServiceModificationProgress) async
    {
        for await output in shell(AppConstants.shared.brewExecutablePath, ["services", "start", serviceToStart.name])
        {
            switch output
            {
            case .standardOutput(let outputLine):
                AppConstants.shared.logger.debug("Services startup output line: \(outputLine)")
                switch outputLine
                {
                case _ where outputLine.contains("Successfully started"):
                    AppConstants.shared.logger.debug("Started \(serviceToStart.name) with no problems")
                default:
                    AppConstants.shared.logger.debug("Service started, but there were some problems")
                }

                serviceModificationProgress.progress += 1

            case .standardError(let errorLine):
                switch errorLine
                {
                case _ where errorLine.contains("must be run as root"):
                    AppConstants.shared.logger.debug("Service must be run as root")

                    servicesState.showError(.couldNotStartService(offendingService: serviceToStart.name, errorThrown: String(localized: "services.error.must-be-run-as-root")))

                default:
                    AppConstants.shared.logger.warning("Could not start service: \(errorLine)")

                    servicesState.showError(.couldNotStartService(offendingService: serviceToStart.name, errorThrown: errorLine))
                }
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
