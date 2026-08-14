//
//  Terminal Output Line - Contains Element from Array.swift
//  Cork
//
//  Created by David Bureš - P on 13.08.2026.
//

import Foundation

public extension TerminalOutput
{
    func containsAny(of substrings: [String]) -> Bool
    {
        substrings.contains
        { searchString in
            switch self
            {
            case .standardOutput(let terminalOutputLine), .standardError(let terminalOutputLine):
                terminalOutputLine.rawOutput.contains(searchString)
            }
        }
    }

    func containsElementFromArray(_ arrayOfComponents: [any RegexComponent]) -> Bool
    {
        arrayOfComponents.contains
        { regexComponent in
            switch self
            {
            case .standardOutput(let terminalOutputLine), .standardError(let terminalOutputLine):
                terminalOutputLine.rawOutput.contains(regexComponent)
            }
        }
    }
}

public extension TerminalOutput.TerminalOutputLine
{
    func containsAny(of substrings: [String]) -> Bool
    {
        substrings.contains(where: { self.rawOutput.contains($0) })
    }
    
    func containsElementFromArray(_ arrayOfComponents: [any RegexComponent]) -> Bool
    {
        arrayOfComponents.contains { self.rawOutput.contains($0) }
    }
}
