//
//  Services Alerts - Descriptions.swift
//  Cork
//
//  Created by David Bureš on 21.07.2024.
//

import Foundation

extension ServicesFatalError
{
    /// The bold text at the top of the error
    var errorDescription: String?
    {
        switch self
        {
        case .couldNotLoadServices:
            return String(localized: "services.error.could-not-load-services")
        case .homebrewOutdated:
            return String(localized: "services.error.homebrew-outdated")
        case .couldNotStartService(let offendingService, _):
            return String(localized: "services.error.could-not-start-service.\(offendingService)")
        case .couldNotStopService(let offendingService, _):
            return String(localized: "services.error.could-not-stop-service.\(offendingService)")
        case .couldNotSynchronizeServices:
            return String(localized: "services.error.could-not-synchronize-services")
        }
    }
}
