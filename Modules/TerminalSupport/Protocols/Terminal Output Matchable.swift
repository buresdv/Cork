//
//  Terminal Output Matchable.swift
//  Cork
//
//  Created by David Bureš - P on 14.02.2026.
//

import Foundation

// MARK: - Case Protocol

public protocol TerminalOutputCase: CaseIterable, Equatable
{
    var patterns: [String] { get }
}

// MARK: - Matchable Protocol

public protocol TerminalOutputMatchable
{
    associatedtype StandardCases: TerminalOutputCase
    associatedtype ErrorCases: TerminalOutputCase
    associatedtype IgnoredCases: TerminalOutputCase
}

// MARK: - Sentinels

/// Use as `ExpectsNoErrors` for matchables that have no error cases
public enum ExpectsNoErrors: TerminalOutputCase
{
    public var patterns: [String] { [] }
}

/// Use as `MatchesNoStandardOutputs` for matchables that have no standard cases
public enum MatchesNoStandardOutputs: TerminalOutputCase
{
    public var patterns: [String] { [] }
}

/// Use as `IgnoresNoOutputs` for matchables that have no ignored cases
public enum IgnoresNoOutputs: TerminalOutputCase
{
    public var patterns: [String] { [] }
}

/// Just pass the output itself without doing any matching
public struct PassesOutputWithoutMatching: TerminalOutputCase
{
    public let string: String
    public var patterns: [String] { [] }

    public static var allCases: [PassesOutputWithoutMatching] { [] }
}

// MARK: - Matching on Single Output

public extension TerminalOutput
{
    /// Match a single streamed output line against a ``TerminalOutputMatchable`` type
    @discardableResult
    func match<T: TerminalOutputMatchable, Result>(
        as _: T.Type,
        onStandardOutput: ((T.StandardCases) -> Result?)? = nil,
        onErrorOutput: ((T.ErrorCases) -> Result?)? = nil,
        onUnimplementedOutput: ((TerminalOutput) -> Result?)? = nil
    ) -> Result?
    {
        if T.IgnoredCases.allCases.contains(where: { $0.patterns.contains(where: { description.contains($0) }) })
        {
            return nil
        }

        switch self
        {
        case .standardOutput(let string):
            if let matched = T.StandardCases.allCases.first(where: { $0.patterns.contains(where: { string.contains($0) }) })
            {
                return onStandardOutput?(matched) ?? nil
            }
            else
            {
                return onUnimplementedOutput?(self) ?? nil
            }

        case .standardError(let string):
            if let matched = T.ErrorCases.allCases.first(where: { $0.patterns.contains(where: { string.contains($0) }) })
            {
                return onErrorOutput?(matched) ?? nil
            }
            else
            {
                return onUnimplementedOutput?(self) ?? nil
            }
        }
    }
}

// MARK: - Matching on Batched Output

public struct BatchedTerminalOutputMatchResult<T: TerminalOutputMatchable>
{
    public let standardOutputs: [T.StandardCases]
    public let errorOutputs: [T.ErrorCases]
    public let unimplementedOutputs: [TerminalOutput]
}

public extension [TerminalOutput]
{
    /// Match a full batched output against a ``TerminalOutputMatchable`` type
    func match<T: TerminalOutputMatchable>(
        as type: T.Type
    ) -> BatchedTerminalOutputMatchResult<T>
    {
        var standardOutputs: [T.StandardCases] = []
        var errorOutputs: [T.ErrorCases] = []
        var unimplementedOutputs: [TerminalOutput] = []

        forEach
        {
            $0.match(
                as: type,
                onStandardOutput: { standardOutputs.append($0); return nil },
                onErrorOutput: { errorOutputs.append($0); return nil },
                onUnimplementedOutput: { unimplementedOutputs.append($0); return nil }
            )
        }

        return .init(
            standardOutputs: standardOutputs,
            errorOutputs: errorOutputs,
            unimplementedOutputs: unimplementedOutputs
        )
    }
}
