//
//  Installation Progress Tracker.swift
//  Cork
//
//  Created by David Bureš - P on 29.04.2026.
//

import BetterProgress
import CorkTerminalFunctions
import Foundation
import CorkShared
import SwiftUI

@Observable
public class InstallationProgressTracker: @MainActor TerminalOutputStreamable
{
    public enum InstallationError: LocalizedError, Equatable
    {
        public enum ImplementedError: LocalizedError, Equatable
        {
            public enum FormulaInstallError: LocalizedError, Equatable
            {
                public enum ImplementedError: LocalizedError, Equatable
                {}

                case implemented(ImplementedError)
                case unimplelented(rawOutput: [TerminalOutput])
            }

            public enum CaskInstallError: LocalizedError, Equatable
            {
                public enum ImplementedError: LocalizedError, Equatable
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

    public enum FormulaInstallMatcher: TerminalOutputMatchable
    {
        public enum StandardCases: TerminalOutputCase, StageDisplayable, Sendable
        {
            public static let allCases: [InstallationProgressTracker.FormulaInstallMatcher.StandardCases] = [
                .findingDependencies,
                .downloadingDependencies(
                    dependencyName: ""
                ),
                .installingDependencies(
                    dependencyName: "",
                    dependencyNumber: .min,
                    totalNumberOfDependencies: .min
                ),
                .downloadingPackage(
                    package: .init(createEmpty: true)
                ),
                .installingPackage(
                    package: .init(createEmpty: true)
                )
            ]
            
            case findingDependencies
            case downloadingDependencies(
                dependencyName: String
            )
            case installingDependencies(
                dependencyName: String,
                dependencyNumber: Int,
                totalNumberOfDependencies: Int
            )
            case downloadingPackage(
                package: MinimalHomebrewPackage
            )
            case installingPackage(
                package: MinimalHomebrewPackage
            )

            public var patterns: [String]
            {
                switch self
                {
                case .findingDependencies:
                    ["Fetching dependencies"]
                case .downloadingDependencies(let dependencyName):
                    ["Fetching \(dependencyName)"]
                case .installingDependencies(let dependencyName, _, _):
                    ["Installing \(dependencyName)"]
                case .downloadingPackage(let package):
                    ["Fetching \(package.name)"]
                case .installingPackage(let package):
                    ["Installing \(package.name)"]
                }
            }
            
            public var stageDescription: LocalizedStringKey
            {
                switch self {
                case .findingDependencies:
                    return "add-package.install.loading-dependencies"
                case .downloadingDependencies(let dependencyName):
                    return "add-package.install.fetching-dependencies"
                case .installingDependencies(let dependencyName, let dependencyNumber, let totalNumberOfDependencies):
                    return "add-package.install.installing-dependencies-\(dependencyNumber)-of-\(totalNumberOfDependencies)"
                case .downloadingPackage(let package):
                    return "add-package.install.downloading-package-\(package.name)"
                case .installingPackage(let package):
                    return "add-package.install.installing-package-\(package.name)"
                }
            }
        }

        public enum ErrorCases: TerminalOutputCase
        {
            case requiresPassword

            public var patterns: [String]
            {
                switch self
                {
                case .requiresPassword:
                    ["a password is required"]
                }
            }
        }

        public typealias IgnoredCases = IgnoresNoOutputs
    }

    public enum CaskInstallMatcher: TerminalOutputMatchable
    {
        public enum StandardCases: TerminalOutputCase, StageDisplayable, Sendable
        {
            public static let allCases: [InstallationProgressTracker.CaskInstallMatcher.StandardCases] = [
                .downloadingCask(.init(createEmpty: true)),
                .installingCask(.init(createEmpty: true)),
                .movingCask(.init(createEmpty: true)),
                .linkingAppToCask(.init(createEmpty: true))
            ]
            
            case downloadingCask(MinimalHomebrewPackage)
            case installingCask(MinimalHomebrewPackage)
            case movingCask(MinimalHomebrewPackage)
            case linkingAppToCask(MinimalHomebrewPackage)

            public var patterns: [String]
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
            
            public var stageDescription: LocalizedStringKey
            {
                switch self
                {
                case .downloadingCask(let caskToInstall):
                    return "add-package.install.downloading-cask-\(caskToInstall.name)"
                case .installingCask(let caskToInstall):
                    return "add-package.install.installing-cask-\(caskToInstall.name)"
                case .movingCask(let caskToInstall):
                    return "add-package.install.moving-cask-\(caskToInstall.name)"
                case .linkingAppToCask(let caskToInstall):
                    return "add-package.install.linking-cask-binary.\(caskToInstall.name)"
                }
            }
        }

        public enum ErrorCases: TerminalOutputCase
        {
            case requiresSudoPassword
            case binaryAlreadyExists
            case wrongArchitecture

            public var patterns: [String]
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

        public typealias IgnoredCases = IgnoresNoOutputs
    }

    public enum InstallStageType
    {
        case formula(FormulaInstallMatcher.StandardCases)
        case cask(CaskInstallMatcher.StandardCases)
    }
    
    public func insertOutput(_ output: CorkTerminalFunctions.TerminalOutput)
    {
        self.outputs.append(output)
    }

    public var outputs: [CorkTerminalFunctions.TerminalOutput] = .init()

    public var standardOutputs: [CorkTerminalFunctions.TerminalOutput] = .init()

    public var standardErrors: [CorkTerminalFunctions.TerminalOutput] = .init()

    public var isStreamedOutputExpanded: Bool = false

    public let packageToInstall: MinimalHomebrewPackage

    public var numberOfPackageDependencies: Int = 0
    public var numberInLineOfPackageCurrentlyBeingFetched: Int = 0
    public var numberInLineOfPackageCurrentlyBeingInstalled: Int = 0

    public var installationProcess: Process?

    public var installStage: InstallStageType

    public var installProgress: Progress

    public init(packageToInstall: MinimalHomebrewPackage)
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
                return .cask(.downloadingCask(packageToInstall))
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
    public func cancel() -> Bool
    {
        guard let installationProcess else { return false }
        installationProcess.terminate()
        self.installationProcess = nil
        return true
    }
}
