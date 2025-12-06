//
//  REGEX Match.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation

public enum RegexError: LocalizedError
{
    case regexFunctionCouldNotMatchAnything

    public var errorDescription: String?
    {
        switch self
        {
        case .regexFunctionCouldNotMatchAnything:
            return String(localized: "error.regex.nothing-matched")
        }
    }
}

public extension String
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
