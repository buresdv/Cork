//
//  Services Alerts - Suggestions.swift
//  Cork
//
//  Created by David Bureš on 21.07.2024.
//

import Foundation

extension ServicesFatalError
{
    var recoverySuggestion: String?
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
