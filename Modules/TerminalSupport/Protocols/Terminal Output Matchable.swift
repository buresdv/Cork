//
//  Terminal Output Matchable.swift
//  Cork
//
//  Created by David Bureš - P on 14.02.2026.
//

import Foundation

/// Protocol for adding support for matching various terminal output strings
public protocol TerminalOutputMatchable
{
    /// Match for these standard outputs
    var matchForStandardOutputs: [String] { get }

    /// March for these standard errors
    var matchForStandardErrors: [String] { get }
}

public extension TerminalOutputMatchable
{
    /// Match the right stage for output
    static func matchStage(
        output: TerminalOutput,
        in cases: [Self],
        handler: (Self) -> Void
    )
    {
        if let matched = cases.first(where: { matchable in
            let standardOutputMatches = matchable.matchForStandardOutputs.contains
            { output.standardOutput.contains($0) }

            let standardErrorMatches = matchable.matchForStandardErrors.contains
            { output.standardError.contains($0) }

            return standardOutputMatches || standardErrorMatches
        })
        {
            handler(matched)
        }
    }
}
