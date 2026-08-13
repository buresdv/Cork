//
//  Terminal Output.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import CorkShared
import Foundation
import SwiftUI

public enum TerminalOutput: Identifiable, Hashable, Equatable, Sendable, CustomStringConvertible
{
    public var id: UUID
    {
        switch self
        {
        case .standardOutput(let terminalOutputLine), .standardError(let terminalOutputLine):
            return terminalOutputLine.id
        }
    }

    public struct TerminalOutputLine: Identifiable, Hashable, Equatable, Sendable, CustomStringConvertible
    {
        public let id: UUID

        public let rawOutput: String

        public let timestamp: Date

        public init(rawOutput: String)
        {
            self.id = .init()
            self.rawOutput = rawOutput
            self.timestamp = .now
        }

        public var description: String
        {
            return self.rawOutput
        }
    }

    case standardOutput(TerminalOutputLine)
    case standardError(TerminalOutputLine)

    public var description: String
    {
        switch self
        {
        case .standardOutput(let output): return output.rawOutput
        case .standardError(let output): return output.rawOutput
        }
    }

    public init(standardOutput rawOutput: String)
    {
        self = .standardOutput(.init(rawOutput: rawOutput))
    }

    public init(standardError rawOutput: String)
    {
        self = .standardError(.init(rawOutput: rawOutput))
    }

    public var containsErrors: Bool
    {
        if case .standardError = self { return true }
        return false
    }

    @ViewBuilder
    public var outputView: some View
    {
        TerminalOutputLineView(outputLine: self)
    }
}

// MARK: - Formatter

public struct TerminalOutputLineFormatStyle: FormatStyle, Sendable
{
    public typealias FormatInput = TerminalOutput.TerminalOutputLine
    public typealias FormatOutput = String

    public init() {}

    public func format(_ value: FormatInput) -> FormatOutput
    {
        return value.rawOutput
    }
}

public extension FormatStyle where Self == TerminalOutputLineFormatStyle
{
    static var terminalOutputLine: TerminalOutputLineFormatStyle
    {
        return TerminalOutputLineFormatStyle()
    }
}

public extension TerminalOutput.TerminalOutputLine
{
    func formatted() -> String
    {
        return TerminalOutputLineFormatStyle().format(self)
    }
}

// MARK: - Views

private struct TerminalOutputLineView: View
{
    let outputLine: TerminalOutput

    var body: some View
    {
        VStack(alignment: .leading, spacing: 5)
        {
            HStack(alignment: .center, spacing: 3)
            {
                switch outputLine {
                case .standardOutput(let terminalOutputLine), .standardError(let terminalOutputLine):
                    Text(terminalOutputLine.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()

                if case .standardError = outputLine
                {
                    Label("error.label", systemImage: "exclamationmark.triangle")
                        .labelStyle(.pill(color: .init(text: .white, background: .init(nsColor: .systemOrange)), iconStyle: .iconIsHidden))
                }
            }

            Text(outputLine.description)
        }
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .contextMenu
        {
            Button
            {
                let pasteboard: NSPasteboard = .general
                pasteboard.declareTypes([.string], owner: nil)
                pasteboard.setString(outputLine.description, forType: .string)
            } label: {
                Text("action.copy")
            }
        }
    }
}

public extension [TerminalOutput]
{
    /// Get only the standard outputs
    var standardOutputs: [String]
    {
        return self.compactMap
        { terminalOutput in
            if case .standardOutput(let terminalOutputLine) = terminalOutput
            {
                return terminalOutputLine.rawOutput
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
            if case .standardError(let terminalOutputLine) = terminalError
            {
                return terminalOutputLine.rawOutput
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
            case .standardOutput(let outputLine):
                let shouldSearchInStandardOutputs: Bool = outputTypes.contains(.standardOutputs)
                let outputContainsSearchString: Bool = outputLine.rawOutput.contains(searchString)

                return shouldSearchInStandardOutputs && outputContainsSearchString

            case .standardError(let errorLine):
                let shouldSearchInErrorOutputs: Bool = outputTypes.contains(.standardErrors)
                let outputContainsSearchString: Bool = errorLine.rawOutput.contains(searchString)

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
            AppConstants.shared.logger.error("Failed while extracting JSON from output because it contained these errors: \(self.standardErrors)")
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

public extension [TerminalOutput]
{
    /// Standardized look for a list of terminal outputs
    @ViewBuilder
    var outputView: some View
    {
        TerminalOutputList(allOutputs: self)
    }
}

private struct TerminalOutputList: View
{
    let allOutputs: [TerminalOutput]

    var body: some View
    {
        List
        {
            ForEach(allOutputs)
            { rawOutput in
                TerminalOutputLineView(outputLine: rawOutput)
                    .id(rawOutput.id)
            }
        }
        .listStyle(.bordered)
        .alternatingRowBackgrounds(.enabled)
        .frame(minWidth: 200, minHeight: 150, maxHeight: 400)
    }
}
