//
//  Terminal Output.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation

public enum TerminalOutput: Sendable
{
    case standardOutput(String)
    case standardError(String)

    public var containsErrors: Bool
    {
        if case .standardError = self { return true }
        return false
    }
}

public extension Array<TerminalOutput>
{
    /// Whether the result of the call has any errors
    var containsErrors: Bool
    {
        contains(where: \.containsErrors)
    }
}
