//
//  REGEX Match.swift
//  Cork
//
//  Created by David Bureš on 19.02.2023.
//

import Foundation

enum RegexError: LocalizedError
{
    case regexFunctionCouldNotMatchAnything
    
    var errorDescription: String?
    {
        switch self {
            case .regexFunctionCouldNotMatchAnything:
                return String(localized: "error.regex.nothing-matched")
        }
    }
}

func regexMatch(from string: String, regex: String) throws -> String
{
    guard let matchedRange = string.range(of: regex, options: .regularExpression) else { throw RegexError.regexFunctionCouldNotMatchAnything }
    
    return String(string[matchedRange])
}
