//
//  Terminal Output Matchable.swift
//  Cork
//
//  Created by David Bureš - P on 14.02.2026.
//

import Foundation

public enum TerminalOutputMatch<T: TerminalOutputMatchable>
{
    case normal(T)
    case error(T)
    case unmatched
}

// MARK: - Protocol

/// Protocol allowing for the matching of Terminal outputs
public protocol TerminalOutputMatchable: CaseIterable
{
    /// Terminal outputs to match to each normal case
    var patterns: [String] { get }

    /// Terminal outputs to ignore
    static var ignoredPatterns: [String]? { get }

    /// Terminal errors to match to each error
    var isError: Bool { get }
}

// MARK: - Default Implementation

public extension TerminalOutputMatchable
{
    static var normalCases: [Self] { allCases.filter { !$0.isError } }
    static var errorCases: [Self] { allCases.filter { $0.isError } }

    static var ignoredPatterns: [String]? { nil }

    static func match(
        _ output: TerminalOutput,
        handler: (TerminalOutputMatch<Self>) -> Void
    )
    {
        if let ignoredPatterns
        {
            switch output
            {
            case .standardOutput(let string), .standardError(let string):
                if ignoredPatterns.contains(where: { string.contains($0) }) { return }
            }
        }

        switch output
        {
        case .standardOutput(let string):
            if let matched = normalCases.first(where: { $0.patterns.contains(where: { string.contains($0) }) })
            {
                handler(.normal(matched))
            }
        case .standardError(let string):
            if let matched = errorCases.first(where: { $0.patterns.contains(where: { string.contains($0) }) })
            {
                handler(.error(matched))
            }
        }
    }
}
