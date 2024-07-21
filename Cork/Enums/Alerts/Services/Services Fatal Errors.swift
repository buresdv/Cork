//
//  Services Fatal Errors.swift
//  Cork
//
//  Created by David Bureš on 12.05.2024.
//

import Foundation

enum ServicesFatalError: LocalizedError
{
    case couldNotLoadServices(error: String), homebrewOutdated

    case couldNotStartService(offendingService: String, errorThrown: String)
    case couldNotStopService(offendingService: String, errorThrown: String)

    case couldNotSynchronizeServices(errorThrown: String)
}
