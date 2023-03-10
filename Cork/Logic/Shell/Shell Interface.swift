//
//  Shell Interface.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

func shell(_ launchPath: String, _ arguments: [String]) async -> TerminalOutput
{
    var allOutput: [String] = .init()
    var allErrors: [String] = .init()
    for await streamedOutput in shell(launchPath, arguments)
    {
        switch streamedOutput
        {
        case let .standardOutput(output):
            allOutput.append(output)
        case let .standardError(error):
            allErrors.append(error)
        }
    }

    return .init(
        standardOutput: allOutput.joined(),
        standardError: allErrors.joined()
    )
}


/// # Usage:
/// for await output in shell(AppConstants.brewExecutablePath.absoluteString, ["install", package.name])
/// {
///    switch output
///    {
///    case let .output(outputLine):
///        // Do something with `outputLine`
///    case let .error(errorLine):
///        // Do something with `errorLine`
///    }
///}
func shell(_ launchPath: String, _ arguments: [String]) -> AsyncStream<StreamedTerminalOutput>
{
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments

    let pipe = Pipe()
    task.standardOutput = pipe
    
    let errorPipe = Pipe()
    task.standardError = errorPipe
    
    do
    {
        try task.run()
    }
    catch
    {
        print(error)
    }

    return AsyncStream { continuation in
        pipe.fileHandleForReading.readabilityHandler = { handler in
            guard let standardOutput = String(data: handler.availableData, encoding: .utf8) else
            {
                return
            }

            guard !standardOutput.isEmpty else { return }

            continuation.yield(.standardOutput(standardOutput))
        }

        errorPipe.fileHandleForReading.readabilityHandler = { handler in
            guard let errorOutput = String(data: handler.availableData, encoding: .utf8) else
            {
                return
            }

            guard !errorOutput.isEmpty else { return }

            continuation.yield(.standardError(errorOutput))
        }

        task.terminationHandler = { _ in
            continuation.finish()
        }
    }
}
