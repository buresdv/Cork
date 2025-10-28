//
//  Terminal Output.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation

public struct TerminalOutput
{
    public var standardOutput: String
    public var standardError: String
}

public enum StreamedTerminalOutput
{
    case standardOutput(String)
    case standardError(String)
}
