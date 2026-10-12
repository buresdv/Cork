//
//  Shell Commands.swift
//  Cork
//
//  Created by David Bureš - P on 28.10.2025.
//

import CorkShared
import Defaults
import FactoryKit
import Foundation
import Subprocess
import System

public actor ShellManager
{
    @Injected(\.appConstants) var appConstants
    
    private var cachedUserEnvironmentObjects: [EnvironmentVariable]?
    private var cachedUserEnvironmentDictionary: [String: String]?
    
    private var cachedProcessEnvironmentObjects: [EnvironmentVariable]?
    private var cachedProcessEnvironmentDictionary: [String: String]?
    
    private var cachedMandatoryEnvironmentObjects: [EnvironmentVariable]?
    private var cachedMandatoryEnvironmentDictionary: [String: String]?
    
    private var cachedCombinedEnvironmentObjects: [EnvironmentVariable]?
    private var cachedCombinedEnvironmentDictionary: [String: String]?
    
    public static let sudoHelperURL: URL = Bundle.main.resourceURL!.appendingPathComponent("Sudo Helper", conformingTo: .executable)
}

public extension ShellManager
{
    private func getUserEnv() async throws -> [EnvironmentVariable]
    {
        let shellPath: FilePath = .init(stringLiteral: ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh")

        let commandResult = try await run(
            .path(shellPath),
            arguments: ["-l", "-c", "env"],
            output: .string(limit: .max),
            error: .string(limit: .max)
        )

        var userEnvironment: [EnvironmentVariable] = .init()

        print("Raw command result: \(commandResult.standardOutput)")
        print("Raw command error: \(commandResult.standardError)")
        
        /// Get individual lines from the output - one line per one env definition
        for line in commandResult.standardOutput.split(separator: "\n")
        {
            print("Raw line: \(line)")
            /// Split the env definition into a name and value
            let splitEnvVariable = line.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            
            guard let userVariableKey = splitEnvVariable.first, let userVariableValue = splitEnvVariable.last else {
                continue
            }
            
            userEnvironment.append(
                .init(
                    key: String(userVariableKey),
                    value: String(userVariableValue)
                )
            )
        }

        return userEnvironment
    }
}

// MARK: - Retrieval functions

// MARK: - User Environment
public extension ShellManager
{
    func userEnvironmentObjects() async throws -> [EnvironmentVariable]
    {
        if let cachedUserEnvironmentObjects
        {
            appConstants.logger.debug("Hit cache for user environment objects")
            
            return cachedUserEnvironmentObjects
        }
        
        let newUserEnvironmentObjects = try await self.getUserEnv()
        
        self.cachedUserEnvironmentObjects = newUserEnvironmentObjects
        
        return newUserEnvironmentObjects
    }
    
    func userEnvironmentDictionary() async throws -> [String: String]
    {
        if let cachedUserEnvironmentDictionary
        {
            appConstants.logger.debug("Hit cache for user environment dictionary")
            
            return cachedUserEnvironmentDictionary
        }
        
        let newUserEnvironmentDictionary = [String: String].init(environmentVariables: try await self.userEnvironmentObjects())
        
        self.cachedUserEnvironmentDictionary = newUserEnvironmentDictionary
        
        return newUserEnvironmentDictionary
    }
}

// MARK: - Process Environment
public extension ShellManager
{
    func processEnvironmentObjects() -> [EnvironmentVariable]
    {
        if let cachedProcessEnvironmentObjects
        {
            appConstants.logger.debug("Hit cache for process environment objects")
            
            return cachedProcessEnvironmentObjects
        }
        
        let newProcessEnvironmentObjects: [EnvironmentVariable] = .init(environment: ProcessInfo.processInfo.environment)
        
        cachedProcessEnvironmentObjects = newProcessEnvironmentObjects
        
        return newProcessEnvironmentObjects
    }
    
    func processEnvironmentDictionary() -> [String: String]
    {
        if let cachedProcessEnvironmentDictionary
        {
            appConstants.logger.debug("Hit cache for process environment dictionary")
            
            return cachedProcessEnvironmentDictionary
        }
        
        let newProcessEnvironmentDictionary: [String: String] = ProcessInfo.processInfo.environment
        
        cachedProcessEnvironmentDictionary = newProcessEnvironmentDictionary
        
        return newProcessEnvironmentDictionary
    }
}

public extension ShellManager
{
    func mandatoryEnvironmentObjects() -> [EnvironmentVariable]
    {
        if let cachedMandatoryEnvironmentObjects
        {
            appConstants.logger.debug("Hit cache for mandatory environment objects")
            
            return cachedMandatoryEnvironmentObjects
        }
        
        var newMandatoryEnvironmentObjects: [EnvironmentVariable] = [EnvironmentVariable]()
        
        newMandatoryEnvironmentObjects.addMandatoryEnvironmentVariables()
        
        cachedMandatoryEnvironmentObjects = newMandatoryEnvironmentObjects
        
        return newMandatoryEnvironmentObjects
    }
    
    func mandatoryEnvironmentDictionary() -> [String: String]
    {
        if let cachedMandatoryEnvironmentDictionary
        {
            appConstants.logger.debug("Hit cache for mandatory environment dictionary")
            
            return cachedMandatoryEnvironmentDictionary
        }
        
        let newMandatoryEnvironmentDictionary: [String: String] = .init(environmentVariables: self.mandatoryEnvironmentObjects())
        
        cachedMandatoryEnvironmentDictionary = newMandatoryEnvironmentDictionary
        
        return newMandatoryEnvironmentDictionary
    }
}

// MARK: - Combined Environment
public extension ShellManager
{
    func combinedEnvironmentObjects() async throws -> [EnvironmentVariable]
    {
        if let cachedCombinedEnvironmentObjects
        {
            appConstants.logger.debug("Hit cache for combined environment objects")
            
            return cachedCombinedEnvironmentObjects
        }
        
        var newCombinedEnvironmentObjects: [EnvironmentVariable]
        
        newCombinedEnvironmentObjects = try await self.processEnvironmentObjects() + self.userEnvironmentObjects()
        
        // MARK: - Add the other mandatory env vars
        
        newCombinedEnvironmentObjects.addMandatoryEnvironmentVariables()
        
        self.cachedCombinedEnvironmentObjects = newCombinedEnvironmentObjects
        
        return newCombinedEnvironmentObjects
    }
    
    func combinedEnvironmentDictionary() async throws -> [String: String]
    {
        if let cachedCombinedEnvironmentDictionary
        {
            appConstants.logger.debug("Hit cache for combined environment dictionary")
            
            return cachedCombinedEnvironmentDictionary
        }
        
        let newCombinedEnvironmentDictionary: [String: String] = .init(environmentVariables: try await self.combinedEnvironmentObjects())
        
        self.cachedCombinedEnvironmentDictionary = newCombinedEnvironmentDictionary
        
        return newCombinedEnvironmentDictionary
    }
}

private extension [EnvironmentVariable]
{
    mutating func addMandatoryEnvironmentVariables()
    {
        Container.shared.appConstants.resolve().logger.debug("Will add mandatory ENV variables")
        
        var incomingEnvironmentVariableArray: [EnvironmentVariable] = self
        
        // TODO: Implement trusting and remove this
        incomingEnvironmentVariableArray.append(.init(key: "HOMEBREW_NO_REQUIRE_TAP_TRUST", value: "1"))
        
        if let proxySettings = AppConstants.shared.proxySettings
        {
            Container.shared.appConstants.resolve().logger.info("Proxy is enabled")
            
            incomingEnvironmentVariableArray.append(.init(key: "ALL_PROXY", value: "\(proxySettings.host):\(proxySettings.port)"))
        }
        
        if Defaults[.isAutomaticCleanupEnabled]
        {
            incomingEnvironmentVariableArray.append(.init(key: "HOMEBREW_NO_INSTALL_CLEANUP", value: "TRUE"))
        }
        
        incomingEnvironmentVariableArray.append(.init(key: "SUDO_ASKPASS", value: ShellManager.sudoHelperURL.path))
        
        self = incomingEnvironmentVariableArray
    }
}

public extension Container
{
    var shellManager: Factory<ShellManager>
    {
        Factory(self)
        {
            ShellManager()
        }
        .singleton
    }
}

@discardableResult
public func shellNonStreaming(
    _ launchPath: URL,
    _ arguments: [String],
    environment: [EnvironmentVariable]? = nil,
    workingDirectory: URL? = nil
) async -> [TerminalOutput]
{
    let task: Process = .init()

    // MARK: - Set working directory if provided

    if let workingDirectory
    {
        AppConstants.shared.logger.info("Working directory configured: \(workingDirectory)")
        task.currentDirectoryURL = workingDirectory
    }
    
    // MARK: - Set up the environment
    var finalEnvironment: [EnvironmentVariable]?
    
    if let environment
    {
        finalEnvironment = try? await Container.shared.shellManager.resolve().combinedEnvironmentObjects() + environment
    }
    else
    {
        finalEnvironment = try? await Container.shared.shellManager.resolve().combinedEnvironmentObjects()
    }

    if let finalEnvironment
    {
        task.environment = .init(environmentVariables: finalEnvironment)
    }
    
    task.launchPath = launchPath.path

    /// Filter out empty things from the arguments so they don't fuck it up
    task.arguments = arguments.filter { $0 != "" }

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
        return []
    }

    let standardOutput = pipe.fileHandleForReading.readDataToEndOfFile()
    let standardError = errorPipe.fileHandleForReading.readDataToEndOfFile()

    print("Raw STDOUT: \(String(data: standardOutput, encoding: .utf8))")
    print("Raw STDERROR: \(String(data: standardError, encoding: .utf8))")

    var allOutputs: [TerminalOutput] = .init()

    if let output = String(data: standardOutput, encoding: .utf8),
       !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
       !output.containsAny(of: Container.shared.appConstants().disqualifyingSymbolsForTerminalOutputs)
    {
        allOutputs.append(.standardOutput(.init(rawOutput: output)))
    }

    if let errorOutput: String = String(data: standardError, encoding: .utf8),
       !errorOutput.isEmpty,
       !errorOutput.containsAny(of: Container.shared.appConstants().disqualifyingSymbolsForTerminalOutputs)
    {
        /// We have to do this fuckery because Homebrew is inconsistent again. The blocks in the consolidated error output are sometimes split by an empty line, and sometimes just not.

        var currentSectionInErrorBlob: String = ""
        var isCurrentSectionInErrorBlobWarning: Bool = false

        for line in errorOutput.components(separatedBy: "\n")
        {
            if line.hasPrefix("Warning:") || line.hasPrefix("Error:") || line.hasPrefix("==>")
            {
                if !currentSectionInErrorBlob.isEmpty
                {
                    if isCurrentSectionInErrorBlobWarning
                    {
                        AppConstants.shared.logger.debug("Hit WARNING state: \(currentSectionInErrorBlob, privacy: .public)")
                        Container.shared.warningsTracker.resolve().insertWarning(warningToInsert: .standardError(.init(rawOutput: currentSectionInErrorBlob)))
                    }
                    else
                    {
                        AppConstants.shared.logger.debug("Hit ERROR state: \(currentSectionInErrorBlob, privacy: .public)")
                        allOutputs.append(.standardError(.init(rawOutput: currentSectionInErrorBlob)))
                    }
                }

                currentSectionInErrorBlob = line
                isCurrentSectionInErrorBlobWarning = line.hasPrefix("Warning:")
            }
            else if !currentSectionInErrorBlob.isEmpty
            {
                currentSectionInErrorBlob.append("\n\(line)")
            }
        }

        /// Idk there's a dangling section
        if !currentSectionInErrorBlob.isEmpty
        {
            if isCurrentSectionInErrorBlobWarning
            {
                AppConstants.shared.logger.debug("Hit WARNING state: \(currentSectionInErrorBlob, privacy: .public)")
                Container.shared.warningsTracker.resolve().insertWarning(warningToInsert: .standardError(.init(rawOutput: currentSectionInErrorBlob)))
            }
            else
            {
                AppConstants.shared.logger.debug("Hit ERROR state: \(currentSectionInErrorBlob, privacy: .public)")
                allOutputs.append(.standardError(.init(rawOutput: currentSectionInErrorBlob)))
            }
        }
    }

    AppConstants.shared.logger.debug("Consolidated outputs: \(allOutputs)")

    return allOutputs
}

/// # Usage:
/// for await output in shell(AppConstants.shared.brewExecutablePath, ["install", package.getPackageName(withPrecision: .precise)])
/// {
///    switch output
///    {
///    case let .output(outputLine):
///        // Do something with `outputLine`
///    case let .error(errorLine):
///        // Do something with `errorLine`
///    }
/// }
public func shell(
    _ launchPath: URL,
    _ arguments: [String],
    environment: [EnvironmentVariable]? = nil,
    workingDirectory: URL? = nil
) async -> AsyncStream<TerminalOutput>
{
    let task: Process = .init()

    // MARK: - Set working directory if provided

    if let workingDirectory
    {
        AppConstants.shared.logger.info("Working directory configured: \(workingDirectory)")
        task.currentDirectoryURL = workingDirectory
    }
    
    // MARK: - Set up the environment
    var finalEnvironment: [EnvironmentVariable]?
    
    if let environment
    {
        finalEnvironment = try? await Container.shared.shellManager.resolve().combinedEnvironmentObjects() + environment
    }
    else
    {
        finalEnvironment = try? await Container.shared.shellManager.resolve().combinedEnvironmentObjects()
    }

    if let finalEnvironment
    {
        task.environment = .init(environmentVariables: finalEnvironment)
    }
    
    task.launchPath = launchPath.path

    /// Filter out empty things from the arguments so they don't fuck it up
    task.arguments = arguments.filter { $0 != "" }

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

    return AsyncStream
    { continuation in
        pipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            if data.isEmpty
            {
                handler.readabilityHandler = nil
                return
            }

            guard let standardOutput = String(data: data, encoding: .utf8)
            else
            {
                return
            }

            guard !standardOutput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !standardOutput.containsAny(of: Container.shared.appConstants().disqualifyingSymbolsForTerminalOutputs)
            else
            {
                AppConstants.shared.logger.debug("""
                Hit an empty or disqualified output.
                Command: \(launchPath.absoluteString) \(arguments)
                """)
                return
            }

            AppConstants.shared.logger.debug("Async terminal output yielded with: \(standardOutput)")

            continuation.yield(.standardOutput(.init(rawOutput: standardOutput)))
        }

        errorPipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            if data.isEmpty
            {
                handler.readabilityHandler = nil
                return
            }

            guard let errorOutput = String(data: data, encoding: .utf8)
            else
            {
                return
            }

            guard !errorOutput.isEmpty,
                  !errorOutput.containsAny(of: Container.shared.appConstants().disqualifyingSymbolsForTerminalOutputs)
            else
            {
                return
            }

            if errorOutput.hasPrefix("Warning:")
            {
                AppConstants.shared.logger.debug("Hit WARNING state: \(errorOutput)")

                Container.shared.warningsTracker.resolve().insertWarning(warningToInsert: .standardError(.init(rawOutput: errorOutput)))
            }
            else
            {
                AppConstants.shared.logger.debug("Git ERROR state: \(errorOutput)")
                continuation.yield(.standardError(.init(rawOutput: errorOutput)))
            }
        }

        task.terminationHandler = { _ in
            pipe.fileHandleForReading.readabilityHandler = nil
            errorPipe.fileHandleForReading.readabilityHandler = nil
            continuation.finish()
        }
    }
}

public func shell(
    _ launchPath: URL,
    _ arguments: [String],
    environment: [EnvironmentVariable]? = nil,
    workingDirectory: URL? = nil
) async -> (stream: AsyncStream<TerminalOutput>, process: Process)
{
    let task: Process = .init()

    // MARK: - Set working directory if provided

    if let workingDirectory
    {
        AppConstants.shared.logger.info("Working directory configured: \(workingDirectory)")
        task.currentDirectoryURL = workingDirectory
    }
    
    // MARK: - Set up the environment
    var finalEnvironment: [EnvironmentVariable]?
    
    if let environment
    {
        finalEnvironment = try? await Container.shared.shellManager.resolve().combinedEnvironmentObjects() + environment
    }
    else
    {
        finalEnvironment = try? await Container.shared.shellManager.resolve().combinedEnvironmentObjects()
    }

    if let finalEnvironment
    {
        task.environment = .init(environmentVariables: finalEnvironment)
    }
    
    task.launchPath = launchPath.path
    task.arguments = arguments.filter { $0 != "" }

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

    let stream: AsyncStream<TerminalOutput> = AsyncStream
    { continuation in
        pipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            if data.isEmpty
            {
                handler.readabilityHandler = nil
                return
            }

            guard let standardOutput = String(data: data, encoding: .utf8)
            else
            {
                return
            }

            guard !standardOutput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !standardOutput.containsAny(of: Container.shared.appConstants().disqualifyingSymbolsForTerminalOutputs)
            else
            {
                return
            }

            AppConstants.shared.logger.debug("Async terminal output yielded with: \(standardOutput)")

            continuation.yield(.standardOutput(.init(rawOutput: standardOutput)))
        }

        errorPipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            if data.isEmpty
            {
                handler.readabilityHandler = nil
                return
            }

            guard let errorOutput = String(data: data, encoding: .utf8)
            else
            {
                return
            }

            guard !errorOutput.isEmpty,
                  !errorOutput.containsAny(of: Container.shared.appConstants().disqualifyingSymbolsForTerminalOutputs)
            else
            {
                return
            }

            if errorOutput.hasPrefix("Warning:")
            {
                AppConstants.shared.logger.debug("Hit WARNING state: \(errorOutput)")

                Container.shared.warningsTracker.resolve().insertWarning(warningToInsert: .standardError(.init(rawOutput: errorOutput)))
            }
            else
            {
                AppConstants.shared.logger.debug("Git ERROR state: \(errorOutput)")
                continuation.yield(.standardError(.init(rawOutput: errorOutput)))
            }
        }

        task.terminationHandler = { _ in
            pipe.fileHandleForReading.readabilityHandler = nil
            errorPipe.fileHandleForReading.readabilityHandler = nil
            continuation.finish()
        }
    }

    return (stream, task)
}
