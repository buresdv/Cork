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
        case .couldNotLoadServices(let error):
            return error
        case .homebrewOutdated:
            return String(localized: "services.error.homebrew-outdated.description")
        case .couldNotStartService(_, let errorThrown):
            return errorThrown
        case .couldNotStopService(_, let errorThrown):
            return errorThrown
        case .couldNotSynchronizeServices(let errorThrown):
            return errorThrown
        }
    }
}
