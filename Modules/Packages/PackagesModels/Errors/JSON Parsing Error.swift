//
//  JSON Parsing Error.swift
//  Cork
//
//  Created by David Bureš on 21.06.2024.
//

import Foundation

public enum JSONParsingError: LocalizedError
{
    case couldNotDecode(failureReason: String)
    case couldNotGetRelevantTapInfo
    

    public var errorDescription: String?
    {
        switch self
        {
        case .couldNotDecode(let failureReason):
            return String(localized: "error.json-parsing.could-not-decode.\(failureReason)")
        case .couldNotGetRelevantTapInfo:
            return String(localized: "error.json-parsing.no-tap-info-in-info-list")
        }
    }
}

