//
//  Terminal Output Streamable.swift
//  Cork
//
//  Created by David Bureš - P on 19.02.2026.
//

import Defaults
import Foundation
import SwiftUI

/// Protocol which adds support for broadcasting real-time outputs of terminal commands
public protocol TerminalOutputStreamable: Observable
{
    /// Collect the real-time output
    var outputs: [TerminalOutput] { get set }

    /// Real-time filtered standard outputs
    var standardOutputs: [TerminalOutput] { get async }

    /// Real-time filtered standard errors
    var standardErrors: [TerminalOutput] { get async }

    /// Add an output to the output tracker
    func insertOutput(_: TerminalOutput)

    associatedtype StreamedOutputsDisplay: View
    /// View for showing the terminal outputs
    var streamedOutputsDisplay: StreamedOutputsDisplay { get }

    /// Whether the output is expanded
    var isStreamedOutputExpanded: Bool { get set }
}

public extension TerminalOutputStreamable
{
    mutating func insertOutput(_ terminalOutput: TerminalOutput)
    {
        self.outputs.append(terminalOutput)
    }
}

// MARK: - View for showing outputs

public extension TerminalOutputStreamable
{
    @MainActor
    var streamedOutputsDisplay: some View
    {
        Group
        {
            if Defaults[.showRealTimeTerminalOutputOfOperations]
            {
                ScrollViewReader
                { proxy in
                    List
                    {
                        ForEach(outputs)
                        { line in
                            Text(line.description)
                                .id(line.id)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(minHeight: 200)
                    .listStyle(.bordered)
                    .onChange(of: outputs)
                    { _, newValue in
                        if let last = newValue.last
                        {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
}
