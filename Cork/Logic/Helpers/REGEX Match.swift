//
//  REGEX Match.swift
//  Cork
//
//  Created by David Bureš on 19.02.2023.
//

import Foundation

enum RegexError: Error
{
    case regexFunctionCouldNotMatchAnything
}

func regexMatch(from string: String, regex: String) throws -> String
{
    guard let matchedRange = string.range(of: regex, options: .regularExpression) else { throw RegexError.regexFunctionCouldNotMatchAnything }
    
    return String(string[matchedRange])
}
