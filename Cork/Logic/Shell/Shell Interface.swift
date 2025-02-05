//
//  Shell Interface.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import Foundation
import CorkShared

@discardableResult
func shell(
    _ launchPath: URL,
    _ arguments: [String],
    environment: [String: String]? = nil,
    workingDirectory: URL? = nil
) async -> TerminalOutput
{
    var allOutput: [String] = .init()
    var allErrors: [String] = .init()
    for await streamedOutput in shell(launchPath, arguments, environment: environment, workingDirectory: workingDirectory)
    {
        switch streamedOutput
        {
        case .standardOutput(let output):
            allOutput.append(output)
        case .standardError(let error):
            allErrors.append(error)
        }
    }

    return .init(
        standardOutput: allOutput.joined(),
        standardError: allErrors.joined()
    )
}

/// # Usage:
/// for await output in shell(AppConstants.shared.brewExecutablePath, ["install", package.name])
/// {
///    switch output
///    {
///    case let .output(outputLine):
///        // Do something with `outputLine`
///    case let .error(errorLine):
///        // Do something with `errorLine`
///    }
/// }
func shell(
    _ launchPath: URL,
    _ arguments: [String],
    environment: [String: String]? = nil,
    workingDirectory: URL? = nil
) -> AsyncStream<StreamedTerminalOutput>
{
    shell(launchPath, arguments, environment: environment, workingDirectory: workingDirectory).stream
}

func shell(
    _ launchPath: URL,
    _ arguments: [String],
    environment: [String: String]? = nil,
    workingDirectory: URL? = nil
) -> (stream: AsyncStream<StreamedTerminalOutput>, process: Process)
{
    let task: Process = .init()

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

    // MARK: - Set up mirrors if the environment variables exist

    if let brewApiDomain = ProcessInfo.processInfo.environment["HOMEBREW_API_DOMAIN"]
    {
        finalEnvironment["HOMEBREW_API_DOMAIN"] = brewApiDomain
    }
    if let brewBottleDomain = ProcessInfo.processInfo.environment["HOMEBREW_BOTTLE_DOMAIN"]
    {
        finalEnvironment["HOMEBREW_BOTTLE_DOMAIN"] = brewBottleDomain
    }

    // MARK: - Set up proxy if it's enabled

    if let proxySettings = AppConstants.shared.proxySettings
    {
        AppConstants.shared.logger.info("Proxy is enabled")
        finalEnvironment["ALL_PROXY"] = "\(proxySettings.host):\(proxySettings.port)"
    }

    // MARK: - Block automatic cleanup is configured

    if !UserDefaults.standard.bool(forKey: "isAutomaticCleanupEnabled")
    {
        finalEnvironment["HOMEBREW_NO_INSTALL_CLEANUP"] = "TRUE"
    }

    AppConstants.shared.logger.debug("Final environment: \(finalEnvironment)")

    // MARK: - Set working directory if provided

    if let workingDirectory
    {
        AppConstants.shared.logger.info("Working directory configured: \(workingDirectory)")
        task.currentDirectoryURL = workingDirectory
    }

    let sudoHelperURL: URL = Bundle.main.resourceURL!.appendingPathComponent("Sudo Helper", conformingTo: .executable)

    finalEnvironment["SUDO_ASKPASS"] = sudoHelperURL.path

    task.environment = finalEnvironment
    task.launchPath = launchPath.absoluteString
    task.arguments = arguments

    let pipe: Pipe = .init()
    task.standardOutput = pipe

    let errorPipe: Pipe = .init()
    task.standardError = errorPipe

    do
    {
        try task.run()
    }
    catch
    {
        AppConstants.shared.logger.error("\(String(describing: error))")
    }

    let stream: AsyncStream<StreamedTerminalOutput> = AsyncStream
    { continuation in
        pipe.fileHandleForReading.readabilityHandler = { handler in
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

        task.terminationHandler = { _ in
            continuation.finish()
        }
    }
    return (stream, task)
}
