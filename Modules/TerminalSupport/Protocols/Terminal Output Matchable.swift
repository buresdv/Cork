//
//  Terminal Output Matchable.swift
//  Cork
//
//  Created by David Bureš - P on 14.02.2026.
//

import Foundation

enum TerminalOutputMatch<T: TerminalOutputMatchable>
{
    case normal(T)
    case error(T)
    case unmatched
}

// MARK: - Protocol
/// Protocol allowing for the matching of Terminal outputs
protocol TerminalOutputMatchable: CaseIterable
{
    /// Terminal outputs to match to each normal case
    var patterns: [String] { get }

    /// Terminal outputs to ignore
    static var ignoredPatterns: [String]? { get }

    /// Terminal errors to match to each error
    var isError: Bool { get }
}

// MARK: - Default Implementation

extension TerminalOutputMatchable
{
    static var normalCases: [Self] { allCases.filter { !$0.isError } }
    static var errorCases: [Self] { allCases.filter { $0.isError } }

    static var ignoredPatterns: [String]? { nil }

    static func match(
        _ output: TerminalOutput,
        handler: (TerminalOutputMatch<Self>) -> Void
    )
    {
        let combinedOutput = output.standardOutput + output.standardError

        if let ignoredPatterns, ignoredPatterns.contains(where: { combinedOutput.contains($0) }) { return }

        if let matched = normalCases.first(where: { $0.patterns.contains(where: { output.standardOutput.contains($0) }) })
        {
            handler(.normal(matched))
        }
        else if let matched = errorCases.first(where: { $0.patterns.contains(where: { output.standardError.contains($0) }) })
        {
            handler(.error(matched))
        }
        else
        {
            handler(.unmatched)
        }
    }
}
