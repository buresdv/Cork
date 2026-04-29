//
//  Installation Progress Tracker.swift
//  Cork
//
//  Created by David Bureš - P on 29.04.2026.
//

import BetterProgress
import CorkTerminalFunctions
import Foundation

@Observable
class InstallationProgressTracker: @MainActor TerminalOutputStreamable
{
    enum InstallationError: LocalizedError
    {
        enum ImplementedError: LocalizedError
        {
            enum FormulaInstallError: LocalizedError
            {
                enum ImplementedError: LocalizedError
                {}

                case implemented(ImplementedError)
                case unimplelented(rawOutput: [TerminalOutput])
            }

            enum CaskInstallError: LocalizedError
            {
                enum ImplementedError: LocalizedError
                {
                    case requiresSudoPassword
                    case binaryAlreadyExists
                    case wrongArchitecture
                    case containsUnexpectedOutputs(rawOutput: [TerminalOutput])
                }

                case implemented(ImplementedError)
                case unimplelented(rawOutput: [TerminalOutput])
            }

            case couldNotSynchronizePackages(PackageSynchronizationError)
            case couldNotInstallFormula(FormulaInstallError)
            case couldNotInstallCask(CaskInstallError)
        }

        case implemented(ImplementedError)
        case unimplemented(rawOutput: [TerminalOutput])
    }

    enum FormulaInstallMatcher: TerminalOutputMatchable
    {
        enum StandardCases: TerminalOutputCase
        {
            static let allCases: [InstallationProgressTracker.FormulaInstallMatcher.StandardCases] = [
                .findingDependencies,
                .downloadingDependencies(dependencyName: ""),
                .installingDependencies(dependencyName: ""),
                .downloadingPackage(package: .init(minimalPackageFromName: "", type: .formula)),
                .installingPackage(package: .init(minimalPackageFromName: "", type: .formula))
            ]
            
            case findingDependencies
            case downloadingDependencies(dependencyName: String)
            case installingDependencies(dependencyName: String)
            case downloadingPackage(package: BrewPackage)
            case installingPackage(package: BrewPackage)

            var patterns: [String]
            {
                switch self
                {
                case .findingDependencies:
                    ["Fetching dependencies"]
                case .downloadingDependencies(let dependencyName):
                    ["Fetching \(dependencyName)"]
                case .installingDependencies(let dependencyName):
                    ["Installing \(dependencyName)"]
                case .downloadingPackage(let package):
                    ["Fetching \(package.name(withPrecision: .precise))"]
                case .installingPackage(let package):
                    ["Installing \(package.name(withPrecision: .precise))"]
                }
            }
        }

        enum ErrorCases: TerminalOutputCase
        {
            case requiresPassword

            var patterns: [String]
            {
                switch self
                {
                case .requiresPassword:
                    ["a password is required"]
                }
            }
        }

        typealias IgnoredCases = IgnoresNoOutputs
    }

    enum CaskInstallMatcher: TerminalOutputMatchable
    {
        enum StandardCases: TerminalOutputCase
        {
            case downloadingCask
            case installingCask
            case movingCask
            case linkingAppToCask

            var patterns: [String]
            {
                switch self
                {
                case .downloadingCask:
                    ["Downloading"]
                case .installingCask:
                    ["Installing Cask", "Purging files"]
                case .movingCask:
                    ["Moving App"]
                case .linkingAppToCask:
                    ["Linking binary"]
                }
            }
        }

        enum ErrorCases: TerminalOutputCase
        {
            case requiresSudoPassword
            case binaryAlreadyExists
            case wrongArchitecture

            var patterns: [String]
            {
                switch self
                {
                case .requiresSudoPassword:
                    ["a password is required"]
                case .binaryAlreadyExists:
                    ["there is already an App at"]
                case .wrongArchitecture:
                    ["/depends on hardware architecture being.+but you are running/"]
                }
            }
        }

        typealias IgnoredCases = IgnoresNoOutputs
    }

    enum InstallStageType
    {
        case formula(FormulaInstallMatcher.StandardCases)
        case cask(CaskInstallMatcher.StandardCases)
    }
    
    func insertOutput(_ output: CorkTerminalFunctions.TerminalOutput)
    {
        self.outputs.append(output)
    }

    var outputs: [CorkTerminalFunctions.TerminalOutput] = .init()

    var standardOutputs: [CorkTerminalFunctions.TerminalOutput] = .init()

    var standardErrors: [CorkTerminalFunctions.TerminalOutput] = .init()

    var isStreamedOutputExpanded: Bool = false

    let packageToInstall: BrewPackage

    var numberOfPackageDependencies: Int = 0
    var numberInLineOfPackageCurrentlyBeingFetched: Int = 0
    var numberInLineOfPackageCurrentlyBeingInstalled: Int = 0

    var installationProcess: Process?

    var installStage: InstallStageType

    var installProgress: Progress

    init(packageToInstall: BrewPackage)
    {
        let progress: Progress = {
            switch packageToInstall.type
            {
            case .formula:
                return .init(totalItems: Self.FormulaInstallMatcher.StandardCases.allCases.count)
            case .cask:
                return .init(totalItems: Self.CaskInstallMatcher.StandardCases.allCases.count)
            }
        }()
        
        let installStageType: InstallStageType = {
            switch packageToInstall.type {
            case .formula:
                return .formula(.findingDependencies)
            case .cask:
                return .cask(.downloadingCask)
            }
        }()

        self.installProgress = progress
        self.installStage = installStageType
        self.packageToInstall = packageToInstall
    }

    deinit
    {
        cancel()
    }

    @discardableResult
    func cancel() -> Bool
    {
        guard let installationProcess else { return false }
        installationProcess.terminate()
        self.installationProcess = nil
        return true
    }
}
