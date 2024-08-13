//
//  JSON Parsing Error.swift
//  Cork
//
//  Created by David Bureš on 21.06.2024.
//

import Foundation

enum JSONParsingError: LocalizedError
{
    case couldNotConvertStringToData(failureReason: String?), couldNotDecode(failureReason: String)
    
    var errorDescription: String?
    {
        switch self {
            case .couldNotConvertStringToData(let failureReason):
                return String(localized: "error.json-parsing.could-not-convert-string-to-data.\(failureReason ?? "")")
            case .couldNotDecode(let failureReason):
                return String(localized: "error.json-parsing.could-not-decode.\(failureReason)")
        }
    }
}
