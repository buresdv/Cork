//
//  Start Service.swift
//  Cork
//
//  Created by David Bureš on 12.05.2024.
//

import Foundation

enum ServiceStartingError: LocalizedError
{
    case couldNotStartService(String)
    
    var errorDescription: String?
    {
        switch self {
            case .couldNotStartService:
                return NSLocalizedString("error.service-startup.could-not-start-service.description", comment: "")
        }
    }
}

extension ServicesTracker
{
    func startService(_ serviceToStart: HomebrewService) async throws
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
                    
                    self.changeServiceStatus(serviceToStart, newStatus: .started)
            case let .standardError(errorLine):
                    switch errorLine
                    {
                        case _ where errorLine.contains("must be run as root"):
                            AppConstants.logger.debug("Service must be run as root")
                        default:
                            AppConstants.logger.warning("Could not start service: \(errorLine)")
                            throw ServiceStartingError.couldNotStartService(errorLine)
                    }
                    
                    self.changeServiceStatus(serviceToStart, newStatus: .error)
            }
        }
    }
}
