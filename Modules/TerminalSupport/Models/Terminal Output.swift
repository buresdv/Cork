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

public extension [TerminalOutput]
{
    /// Get only the standard outputs
    var standardOutputs: [String]
    {
        return self.compactMap
        { terminalOutput in
            if case .standardOutput(let outputString) = terminalOutput
            {
                return outputString
            }
            else
            {
                return nil
            }
        }
    }

    /// Get only the errors
    var standardErrors: [String]
    {
        return self.compactMap
        { terminalError in
            if case .standardError(let errorString) = terminalError
            {
                return errorString
            }
            else
            {
                return nil
            }
        }
    }
}

public extension [TerminalOutput]
{
    /// Whether the result of the call has any errors
    var containsErrors: Bool
    {
        contains(where: \.containsErrors)
    }
}

public extension [TerminalOutput]
{
    /// Whether to look for the particular string in outputs or errors
    enum ContainsLookupType
    {
        case standardOutputs
        case standardErrors
    }

    /// Return a boolean value that indicates whether a String is present in the specified output type for this ``TerminalOutput`` array
    func contains(
        _ searchString: String,
        in outputTypes: ContainsLookupType...
    ) -> Bool
    {
        return self.contains
        { terminalOutput in
            switch terminalOutput
            {
            case .standardOutput(let outputString):
                let shouldSearchInStandardOutputs: Bool = outputTypes.contains(.standardOutputs)
                let outputContainsSearchString: Bool = outputString.contains(searchString)

                return shouldSearchInStandardOutputs && outputContainsSearchString

            case .standardError(let errorString):
                let shouldSearchInErrorOutputs: Bool = outputTypes.contains(.standardErrors)
                let outputContainsSearchString: Bool = errorString.contains(errorString)

                return shouldSearchInErrorOutputs && outputContainsSearchString
            }
        }
    }
}
