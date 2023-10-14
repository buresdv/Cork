//
//  Shell Interface.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation

@discardableResult
func shell(
    _ launchPath: URL,
    _ arguments: [String],
    environment: [String: String]? = nil
) async -> TerminalOutput
{
    var allOutput: [String] = .init()
    var allErrors: [String] = .init()
    for await streamedOutput in shell(launchPath, arguments, environment: environment)
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
/// for await output in shell(AppConstants.brewExecutablePath, ["install", package.name])
/// {
///    switch output
///    {
///    case let .output(outputLine):
///        // Do something with `outputLine`
///    case let .error(errorLine):
///        // Do something with `errorLine`
///    }
///}
func shell(
    _ launchPath: URL,
    _ arguments: [String],
    environment: [String: String]? = nil
) -> AsyncStream<StreamedTerminalOutput> {
    let task = Process()
    
    var finalEnvironment: [String: String] = .init()
    
    // MARK: - Set up the $HOME environment variable so brew commands work on versions 4.1 and up
    if var environment
    {
        environment["HOME"] = FileManager.default.homeDirectoryForCurrentUser.path
        finalEnvironment = environment
    }
    else
    {
        finalEnvironment = ["HOME": FileManager.default.homeDirectoryForCurrentUser.path]
    }
    
    // MARK: - Set up proxy if it's enabled
    if let proxySettings = AppConstants.proxySettings
    {
        print("Proxy is enabled")
        finalEnvironment["ALL_PROXY"] = "\(proxySettings.host):\(proxySettings.port)"
    }
    
    task.environment = finalEnvironment
    task.launchPath = launchPath.absoluteString
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
