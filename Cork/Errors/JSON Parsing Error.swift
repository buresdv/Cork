//
//  JSON Parsing Error.swift
//  Cork
//
//  Created by David Bureš on 21.06.2024.
//

import Foundation

enum JSONParsingError: Error
{
    case couldNotConvertStringToData(failureReason: String?), couldNotDecode(failureReason: String)
}
