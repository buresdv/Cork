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
    /// Type-erased REGEX
    // TODO: Make this not type-erased
    var patterns: [Regex<AnyRegexOutput>] { get }
}

// MARK: - Matchable Protocol

public protocol TerminalOutputMatchable
{
    associatedtype StandardCases: TerminalOutputCase
    associatedtype ErrorCases: TerminalOutputCase
    associatedtype IgnoredCases: TerminalOutputCase
}

// MARK: - Sentinels

/// Use as `ErrorCases` for matchables that have no error cases
public enum ExpectsNoErrors: TerminalOutputCase
{
    public var patterns: [Regex<AnyRegexOutput>] { [] }
}

/// Use as `StandardCases` for matchables that have no standard cases
public enum MatchesNoStandardOutputs: TerminalOutputCase
{
    public var patterns: [Regex<AnyRegexOutput>] { [] }
}

/// Use as `IgnoredCases` for matchables that have no ignored cases
public enum IgnoresNoOutputs: TerminalOutputCase
{
    public var patterns: [Regex<AnyRegexOutput>] { [] }
}

/// Just pass the output itself without doing any matching
public struct PassesOutputWithoutMatching: TerminalOutputCase
{
    public let string: String
    public var patterns: [Regex<AnyRegexOutput>] { [] }

    public static var allCases: [PassesOutputWithoutMatching] { [] }
}

// MARK: - Regex Matching

private extension String
{
    /// REGEX-match **any** part of the output
    func matchesAny(of patterns: [Regex<AnyRegexOutput>]) -> Bool
    {
        patterns.contains { firstMatch(of: $0) != nil }
    }
}

// MARK: - Matching on Single Output

public extension TerminalOutput
{
    /// Match a single streamed output line against a ``TerminalOutputMatchable`` type
    /// Because Homebrew is fucked in their output routing, when it matches an STDERR, it tries to match it against any STDOUT first before throwing it in unimplemented
    @discardableResult
    func match<Type: TerminalOutputMatchable, Result>(
        as _: Type.Type,
        onStandardOutput: ((Type.StandardCases) -> Result?)? = nil,
        onErrorOutput: ((Type.ErrorCases) -> Result?)? = nil,
        onUnimplementedOutput: ((TerminalOutput) -> Result?)? = nil
    ) -> Result?
    {
        if Type.IgnoredCases.allCases.contains(where: { description.matchesAny(of: $0.patterns) })
        {
            return nil
        }

        switch self
        {
        case .standardOutput(let string):
            if let matched = Type.StandardCases.allCases.first(where: { string.matchesAny(of: $0.patterns) })
            {
                return onStandardOutput?(matched) ?? nil
            }
            else
            {
                return onUnimplementedOutput?(self) ?? nil
            }

        case .standardError(let string):
            if let matched = Type.ErrorCases.allCases.first(where: { string.matchesAny(of: $0.patterns) })
            {
                return onErrorOutput?(matched) ?? nil
            }
            else if let matched = Type.StandardCases.allCases.first(where: { string.matchesAny(of: $0.patterns) })
            {
                return onStandardOutput?(matched) ?? nil
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
