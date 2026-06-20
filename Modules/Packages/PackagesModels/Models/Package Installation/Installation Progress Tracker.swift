//
//  Installation Progress Tracker.swift
//  Cork
//
//  Created by David Bureš - P on 29.04.2026.
//

import BetterProgress
import CorkShared
import CorkTerminalFunctions
import Foundation
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
                {
                    case requiresSudoPassword

                    public var errorDescription: String?
                    {
                        switch self
                        {
                        case .requiresSudoPassword:
                            return String(localized: "add-package.install.requires-sudo-password")
                        }
                    }
                }

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

                    public var errorDescription: String?
                    {
                        switch self
                        {
                        case .requiresSudoPassword:
                            return String(localized: "add-package.install.requires-sudo-password")
                        case .binaryAlreadyExists:
                            return String(localized: "add-package.install.binary-already-exists")
                        case .wrongArchitecture:
                            return String(localized: "add-package.install.wrong-architecture")
                        case .containsUnexpectedOutputs(let rawOutput):
                            return String(localized: "add-package.install.contains-unexpected-outputs")
                        }
                    }

                    public var recoverySuggestion: String?
                    {
                        switch self
                        {
                        case .requiresSudoPassword:
                            return String(localized: "add-package.install.requires-sudo-password.recovery-suggestion")
                        case .binaryAlreadyExists:
                            return String(localized: "add-package.install.binary-already-exists.recovery-suggestion")
                        case .wrongArchitecture:
                            return String(localized: "add-package.install.wrong-architecture.recovery-suggestion")
                        case .containsUnexpectedOutputs(let rawOutput):
                            return String(localized: "add-package.install.contains-unexpected-outputs.recovery-suggestion")
                        }
                    }
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
        public enum StandardCases: TerminalOutputCase, Sendable
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
                    ["Fetching \(package.name(withPrecision: .precise))"]
                case .installingPackage(let package):
                    ["Installing \(package.name(withPrecision: .precise))"]
                }
            }

            public var stageDescription: String
            {
                switch self
                {
                case .findingDependencies:
                    return String(localized: "add-package.install.loading-dependencies")
                case .downloadingDependencies:
                    return String(localized: "add-package.install.fetching-dependencies")
                case .installingDependencies(_, let dependencyNumber, let totalNumberOfDependencies):
                    return String(localized: "add-package.install.installing-dependencies-\(dependencyNumber)-of-\(totalNumberOfDependencies)")
                case .downloadingPackage(let package):
                    return String(localized: "add-package.install.downloading-package-\(package.name(withPrecision: .inlineFormatted))")
                case .installingPackage(let package):
                    return String(localized: "add-package.install.installing-package-\(package.name(withPrecision: .inlineFormatted))")
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
        public enum StandardCases: TerminalOutputCase, Sendable
        {
            case downloadingCask
            case installingCask
            case movingCask
            case linkingAppToCask

            public var progressPercentageForCase: Double
            {
                switch self
                {
                case .downloadingCask:
                    return 25
                case .installingCask:
                    return 80
                case .movingCask:
                    return 90
                case .linkingAppToCask:
                    return 95
                }
            }

            public var patterns: [String]
            {
                switch self
                {
                case .downloadingCask:
                    ["Downloading", "Fetching downloads"]
                case .installingCask:
                    ["Installing Cask", "Purging files"]
                case .movingCask:
                    ["Moving App"]
                case .linkingAppToCask:
                    ["Linking"]
                }
            }

            public func stageDescription(withPackage: MinimalHomebrewPackage) -> String
            {
                switch self
                {
                case .downloadingCask:
                    return String(localized: "add-package.install.downloading-cask-\(withPackage.name(withPrecision: .precise))")
                case .installingCask:
                    return String(localized: "add-package.install.installing-cask-\(withPackage.name(withPrecision: .precise))")
                case .movingCask:
                    return String(localized: "add-package.install.moving-cask-\(withPackage.name(withPrecision: .precise))")
                case .linkingAppToCask:
                    return String(localized: "add-package.install.linking-cask-binary.\(withPackage.name(withPrecision: .precise))")
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

        public enum IgnoredCases: TerminalOutputCase
        {
            case trustWarning
            case installOverview

            public var patterns: [String]
            {
                switch self
                {
                case .trustWarning:
                    ["The following taps are not trusted"]
                case .installOverview:
                    ["Would install 1 cask"]
                }
            }
        }
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
                return .init(
                    totalItems: Self.FormulaInstallMatcher.StandardCases.allCases.count,
                    underProgressBarText: "add-package.install.ready"
                )
            case .cask:
                return .init(
                    totalItems: Self.CaskInstallMatcher.StandardCases.allCases.count,
                    underProgressBarText: "add-package.install.ready"
                )
            }
        }()

        let installStageType: InstallStageType = {
            switch packageToInstall.type
            {
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
    public func cancel() -> Bool
    {
        guard let installationProcess else { return false }
        installationProcess.terminate()
        self.installationProcess = nil
        return true
    }
}
