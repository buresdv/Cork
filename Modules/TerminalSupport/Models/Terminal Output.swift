//
//  Terminal Output.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation

public enum TerminalOutput: Identifiable, Hashable, Equatable, Sendable, CustomStringConvertible
{
    public var id: Self
    {
        return self
    }

    case standardOutput(String)
    case standardError(String)

    public var description: String
    {
        switch self
        {
        case .standardOutput(let outputString):
            return outputString
        case .standardError(let errorString):
            return errorString
        }
    }

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

public extension [TerminalOutput]
{
    /// Designate the output as purely for retrieving JSON
    /// By designating a command as "JSON Retrieval" command, the system will only care about the first output, and automatically transform the output array into just the first output - which is expected to contains the JSON response
    /// - Parameter failOnAnyErrorsPresent: Set whether the command should fail if there any any errors at all. If set to `false`, errors being present in the output will get ignored. If set to `true`, the operation will fail and return `nil`
    /// - Returns: Optional transformed JSON output into `Data` for further parsing in its own respective JSON parser
    func getJsonFromOutput(
        failOnAnyErrorsPresent: Bool
    ) -> Data?
    {
        if failOnAnyErrorsPresent, self.containsErrors
        {
            return nil
        }

        guard let firstElementInOutputArray: String = self.standardOutputs.first
        else
        {
            return nil
        }

        return firstElementInOutputArray.data(using: .utf8)
    }
}
