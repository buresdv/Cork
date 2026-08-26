//
//  Decoding Error - Show the actual problem.swift
//  Cork
//
//  Created by David Bureš - P on 26.08.2026.
//

import Foundation

public extension DecodingError
{
    var rawDebugDescription: String
    {
        switch self
        {
        case .keyNotFound(_, let context),
             .valueNotFound(_, let context),
             .typeMismatch(_, let context),
             .dataCorrupted(let context):
            return context.debugDescription

        @unknown default:
            return String(describing: self)
        }
    }
}
