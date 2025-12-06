//
//  Intent Error.swift
//  Cork
//
//  Created by David Bureš on 13.11.2024.
//

import Foundation

public enum IntentError: LocalizedError
{
    case failedWhilePerformingIntent

    public var errorDescription: String?
    {
        switch self
        {
        case .failedWhilePerformingIntent:
            return String(localized: "error.intents.general-failure")
        }
    }
}
