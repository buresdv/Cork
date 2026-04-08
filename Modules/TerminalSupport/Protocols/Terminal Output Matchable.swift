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

/// Use as `IgnoresNoOutputs` for matchables that have no ignored cases
public enum IgnoresNoOutputs: TerminalOutputCase
{
    public var patterns: [String] { [] }
}

// MARK: - Matching on Single Output

public extension TerminalOutput
{
    /// Match a single streamed output line against a ``TerminalOutputMatchable`` type
    func match<T: TerminalOutputMatchable>(
        as _: T.Type,
        onStandardOutput: ((T.StandardCases) -> Void)? = nil,
        onErrorOutput: ((T.ErrorCases) -> Void)? = nil,
        onUnimplementedOutput: (() -> Void)? = nil
    )
    {
        if T.IgnoredCases.allCases.contains(where: { $0.patterns.contains(where: { description.contains($0) }) })
        {
            return
        }

        switch self
        {
        case .standardOutput(let string):
            if let matched = T.StandardCases.allCases.first(where: { $0.patterns.contains(where: { string.contains($0) }) })
            {
                onStandardOutput?(matched)
            }
            else
            {
                onUnimplementedOutput?()
            }

        case .standardError(let string):
            if let matched = T.ErrorCases.allCases.first(where: { $0.patterns.contains(where: { string.contains($0) }) })
            {
                onErrorOutput?(matched)
            }
            else
            {
                onUnimplementedOutput?()
            }
        }
    }
}

// MARK: - Matching on Batched Output

public extension [TerminalOutput]
{
    /// Match a full batched output against a ``TerminalOutputMatchable`` type
    func match<T: TerminalOutputMatchable>(
        as type: T.Type,
        onStandardOutput: ((T.StandardCases) -> Void)? = nil,
        onErrorOutput: ((T.ErrorCases) -> Void)? = nil,
        onUnimplementedOutput: (() -> Void)? = nil
    )
    {
        forEach
        {
            $0.match(
                as: type,
                onStandardOutput: onStandardOutput,
                onErrorOutput: onErrorOutput,
                onUnimplementedOutput: onUnimplementedOutput
            )
        }
    }
}
