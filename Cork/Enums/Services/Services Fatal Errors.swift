//
//  Services Fatal Errors.swift
//  Cork
//
//  Created by David Bureš on 12.05.2024.
//

import Foundation

enum ServicesFatalError: LocalizedError
{
    case couldNotLoadServices(error: String)

    case couldNotStartService(offendingService: String, errorThrown: String)
    case couldNotStopService(offendingService: String, errorThrown: String)

    case couldNotSynchronizeServices(errorThrown: String)

    var errorDescription: String?
    {
        switch self
        {
        case .couldNotLoadServices:
            return String(localized: "services.error.could-not-load-services")
        case let .couldNotStartService(offendingService, _):
            return String(localized: "services.error.could-not-start-service.\(offendingService)")
        case let .couldNotStopService(offendingService, _):
            return String(localized: "services.error.could-not-stop-service.\(offendingService)")
        case .couldNotSynchronizeServices:
            return String(localized: "services.error.could-not-synchronize-services")
        }
    }

    var failureReason: String
    {
        switch self
        {
        case let .couldNotLoadServices(error):
            return error
        case let .couldNotStartService(_, errorThrown):
            return errorThrown
        case let .couldNotStopService(_, errorThrown):
            return errorThrown
        case let .couldNotSynchronizeServices(errorThrown):
            return errorThrown
        }
    }
}
