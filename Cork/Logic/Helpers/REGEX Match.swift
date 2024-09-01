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
        switch self
        {
        case .regexFunctionCouldNotMatchAnything:
            return String(localized: "error.regex.nothing-matched")
        }
    }
}

extension String
{
    
    /// Match a string according to a specified REGEX
    /// - Parameter regex: Regex string to match
    /// - Returns: A matched string if matching was successful, ``nil`` if nothing got matched
    func regexMatch(_ regex: String) throws -> String
    {
        guard let matchedRange = self.range(of: regex, options: .regularExpression) else
        {
            throw RegexError.regexFunctionCouldNotMatchAnything
        }
        
        return String(self[matchedRange])
    }
}
