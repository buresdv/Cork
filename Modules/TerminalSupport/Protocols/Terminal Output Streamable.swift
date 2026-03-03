//
//  Terminal Output Streamable.swift
//  Cork
//
//  Created by David Bureš - P on 19.02.2026.
//

import Foundation
import Defaults

/*
/// Protocol which adds support for broadcasting real-time outputs of terminal commands
public protocol TerminalOutputStreamable: Observable
{
    /// Whether real time terminal outputs should be streamed
    var shouldShowRealTimeOutputs: Bool { get }
    
    /// Attach to a process and stream its real-time output
    func realTimeOutput(process: Process, processPipe: Pipe, errorPipe: Pipe) async throws -> AsyncStream<TerminalOutput>
}

public extension TerminalOutputStreamable
{
    static var shouldShowRealTimeOutputs: Bool
    {
        return Defaults[.showRealTimeTerminalOutputOfOperations]
    }
    
    static func realTimeOutput(process: Process, processPipe: Pipe, errorPipe: Pipe) async throws -> AsyncStream<TerminalOutput>
    {
        return AsyncStream
        { continuation in
            processPipe.fileHandleForReading.readabilityHandler =
            { handler in
                guard let standardOutput = String(data: handler.availableData, encoding: .utf8)
                else
                {
                    return
                }
                
                guard !standardOutput.isEmpty
                else
                {
                    return
                }
                
                continuation.yield(.standardOutput(standardOutput))
            }
            
            errorPipe.fileHandleForReading.readabilityHandler = { handler in
                guard let errorOutput = String(data: handler.availableData, encoding: .utf8)
                else
                {
                    return
                }
                
                guard !errorOutput.isEmpty else { return }
                
                continuation.yield(.standardError(errorOutput))
            }
            
            process.terminationHandler = { _ in
                continuation.finish()
            }
        }
    }
}
*/
