//
//  Update Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import CorkModels
import CorkShared
import CorkTerminalFunctions
import FactoryKit
import Foundation
import SwiftUI

@Observable @MainActor
public class UpdateProgressTracker: @MainActor TerminalOutputStreamable
{
    public var outputs: [CorkTerminalFunctions.TerminalOutput]

    @Injected(\.appConstants) @ObservationIgnored var appConstants

    public var isStreamedOutputExpanded: Bool = false

    var updateProgress: Progress

    let outdatedPackagesTrackerToUse: OutdatedPackagesTracker

    let packageUpdatingType: UpdatePackagesView.UpdateType

    var updatingState: PackageUpdatingStage

    var packageBeingCurrentlyUpdated: OutdatedPackage?

    enum PackageUpdatingStage
    {
        case updating(type: UpdatePackagesView.UpdateType)
        case finished
        case erroredOut(results: [UpdateProgressTracker.IndividualPackageUpdatingError])
        case completedWithUnexpectedOutputs(unimplementedOutputs: [TerminalOutput])
        case noUpdatesAvailable
    }

    public init(
        outdatedPackagesTrackerToUse: OutdatedPackagesTracker
    )
    {
        self.outputs = []
        self.packageBeingCurrentlyUpdated = nil

        self.outdatedPackagesTrackerToUse = outdatedPackagesTrackerToUse

        let updatingType: UpdatePackagesView.UpdateType = {
            if outdatedPackagesTrackerToUse.areAllOutdatedPackagesMarkedForUpdating
            {
                return .complete
            }
            else
            {
                return .partial(packagesToUpdate: outdatedPackagesTrackerToUse.packagesMarkedForUpdating)
            }
        }()
        
        self.packageUpdatingType = updatingType

        self.updateProgress = {
            switch updatingType
            {
            case .partial:
                return .init(
                    totalItems: outdatedPackagesTrackerToUse.packagesMarkedForUpdating.count,
                    underProgressBarText: "add-package.install.ready"
                )
            case .complete:
                return .init(
                    totalItems: 1,
                    underProgressBarText: "add-package.install.ready"
                )
            }
        }()

        self.updatingState = .updating(type: self.packageUpdatingType)
    }

    // MARK: - Matchers

    public enum UpdateProcessMatcher: TerminalOutputMatchable, CaseIterable
    {
        public enum StandardCases: String, CustomStringConvertible, TerminalOutputCase
        {
            case downloading = "update-packages.detail-stage.downloading"
            case pouring = "update-packages.detail-stage.pouring"
            case cleanup = "update-packages.detail-stage.cleanup"
            case backingUp = "update-packages.detail-stage.backing-up"
            case linking = "update-packages.detail-stage.linking"

            public var patterns: [Regex<AnyRegexOutput>]
            {
                switch self
                {
                case .downloading:
                    [.init(#/Downloading/#), .init(#/Fetching/#)]
                case .pouring:
                    [.init(#/Pouring/#), .init(#/Running installer/#), .init(#/Upgrading/#)]
                case .cleanup:
                    [.init(#/cleanup/#), .init(#/Removing/#), .init(#/Unlinking/#), .init(#/Uninstalling/#), .init(#/Purging/#)]
                case .backingUp:
                    [.init(#/Backing/#)]
                case .linking:
                    [.init(#/Moving/#), .init(#/Linking/#)]
                }
            }

            public var description: String
            {
                return String(localized: String.LocalizationValue(rawValue))
            }
        }

        public enum ErrorCases: TerminalOutputCase
        {
            case multipleUpdatesFailed

            public var patterns: [Regex<AnyRegexOutput>]
            {
                switch self
                {
                case .multipleUpdatesFailed:
                    [.init(#/Problems with multiple casks/#), .init(#/Problems with multiple formulae/#)]
                }
            }
        }

        public enum IgnoredCases: TerminalOutputCase
        {
            case updateOverview
            case tapUpdate
            case noChecksumDefined
            case updateResultsSummary
            case additionalTools
            case completionsInstalledToPath
            case quittingApplication
            case applicationQuitSuccessfully
            case reopeningApplication

            public var patterns: [Regex<AnyRegexOutput>]
            {
                switch self
                {
                case .updateOverview: [.init(#/Would upgrade \d+ outdated packages/#), .init(#/Upgrading \d+ outdated packages/#)]
                case .tapUpdate: [.init(#/tap/#)]
                case .noChecksumDefined: [.init(#/No checksum defined for/#)]
                case .updateResultsSummary: [.init(#/Upgraded \d+ outdated packages/#)]
                case .additionalTools: [.init(#/includes additional tools and libraries not included in the regular/#)]
                case .completionsInstalledToPath: [.init(#/completions have been installed to/#)]
                case .quittingApplication: [.init(#/Quitting application/#)]
                case .applicationQuitSuccessfully: [.init(#/quit successfully/#)]
                case .reopeningApplication: [.init(#/application closed during upgrade/#)]
                }
            }
        }
    }

    public enum IndividialPackageUpdatingStage: TerminalOutputMatchable
    {
        public enum StandardCases: CustomStringConvertible, TerminalOutputCase
        {
            case downloading
            case installingUpdate
            case cleaningUp

            public var patterns: [Regex<AnyRegexOutput>]
            {
                switch self
                {
                case .downloading:
                    [.init(#/Fetching/#)]
                case .installingUpdate:
                    [.init(#/Reinstalling/#), .init(#/Installing/#), .init(#/Pouring/#)]
                case .cleaningUp:
                    [.init(#/cleanup/#), .init(#/Uninstalling Cask/#), .init(#/Uninstalling Formula/#), .init(#/Removing App/#)]
                }
            }

            public var description: String
            {
                switch self
                {
                case .downloading:
                    return String(localized: String.LocalizationValue("update-packages.detail-stage.downloading"))
                case .installingUpdate:
                    return String(localized: String.LocalizationValue("update-packages.detail-stage.installing-update"))
                case .cleaningUp:
                    return String(localized: String.LocalizationValue("update-packages.detail-stage.cleanup"))
                }
            }
        }

        public enum ErrorCases: TerminalOutputCase
        {
            /// Post-install scripts provided by the package failed
            case postInstallStepFailed

            /// Expects password
            case terminalRequired

            public var patterns: [Regex<AnyRegexOutput>]
            {
                switch self
                {
                case .postInstallStepFailed:
                    [.init(#/post-install step did not complete successfully/#)]
                case .terminalRequired:
                    [.init(#/a terminal is required to read the password/#)]
                }
            }
        }

        public enum IgnoredCases: TerminalOutputCase
        {
            case caveats
            case overridingSuccessfully

            public var patterns: [Regex<AnyRegexOutput>]
            {
                switch self
                {
                case .caveats:
                    [.init(#/Caveats/#)]
                case .overridingSuccessfully:
                    [.init(#/It seems there is already an App at.*overwriting/#)]
                }
            }
        }
    }

    public enum IndividualPackageUpdatingError: LocalizedError, Identifiable
    {
        public enum ImplementedError: LocalizedError
        {
            case thereIsAlreadyAppAtPath(path: String)
            case postInstallStepFailed(rawOutput: String)
            case terminalRequired
            
            public var errorDescription: String?
            {
                switch self
                {
                case .thereIsAlreadyAppAtPath(let path):
                    return String(localized: "error.app-already-exists-at.\(path)")
                case .postInstallStepFailed(let rawOutput):
                    return String(localized: "error.post-install-step-failed.\(rawOutput)")
                case .terminalRequired:
                    return String(localized: "error.terminal-required")
                }
            }
        }

        case implemented(
            failedPackage: OutdatedPackage,
            error: ImplementedError
        )

        case unimplemented(
            failedPackage: OutdatedPackage,
            rawOutput: String
        )

        public var id: UUID
        {
            switch self
            {
            case .implemented(let failedPackage, _):
                return failedPackage.package.id
            case .unimplemented(let failedPackage, _):
                return failedPackage.package.id
            }
        }
    }
}
