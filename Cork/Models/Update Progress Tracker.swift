//
//  Update Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 04.07.2022.
//

import CorkModels
import CorkTerminalFunctions
import FactoryKit
import Foundation
import SwiftUI
import CorkShared

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
        case noUpdatesAvailable
    }
    
    public init(
        outdatedPackagesTrackerToUse: OutdatedPackagesTracker
    ) {
        self.outputs = []
        self.packageBeingCurrentlyUpdated = nil

        self.outdatedPackagesTrackerToUse = outdatedPackagesTrackerToUse
        
        self.updateProgress = Progress(totalUnitCount: Int64(self.outdatedPackagesTrackerToUse.packagesMarkedForUpdating.count))
        
        self.packageUpdatingType = {
            if outdatedPackagesTrackerToUse.areAllOutdatedPackagesMarkedForUpdating
            {
                return .complete
            }
            else
            {
                return .partial(packagesToUpdate: outdatedPackagesTrackerToUse.packagesMarkedForUpdating)
            }
        }()

        self.updatingState = .updating(type: self.packageUpdatingType)
    }
    
    // MARK: - Matchers

    public enum UpdateProcessMatcher: TerminalOutputMatchable
    {
        public enum StandardCases: LocalizedStringKey, CustomStringConvertible, TerminalOutputCase
        {
            case downloading = "update-packages.detail-stage.downloading"
            case pouring = "update-packages.detail-stage.pouring"
            case cleanup = "update-packages.detail-stage.cleanup"
            case backingUp = "update-packages.detail-stage.backing-up"
            case linking = "update-packages.detail-stage.linking"

            public var patterns: [String]
            {
                switch self
                {
                case .downloading:
                    ["Downloading"]
                case .pouring:
                    ["Pouring"]
                case .cleanup:
                    ["cleanup"]
                case .backingUp:
                    ["Backing App"]
                case .linking:
                    ["Moving App", "Linking"]
                }
            }

            public var description: String
            {
                switch self
                {
                case .downloading:
                    return "Downloading"
                case .pouring:
                    return "Pouring"
                case .cleanup:
                    return "Cleanup"
                case .backingUp:
                    return "Backing Up"
                case .linking:
                    return "Linking"
                }
            }
        }

        public typealias ErrorCases = ExpectsNoErrors

        public enum IgnoredCases: TerminalOutputCase
        {
            case tapUpdate
            case noChecksumDefined

            public var patterns: [String]
            {
                switch self
                {
                case .tapUpdate: ["tap"]
                case .noChecksumDefined: ["No checksum defined for"]
                }
            }
        }
    }

    public enum IndividialPackageUpdatingStage: TerminalOutputMatchable
    {
        public enum StandardCases: LocalizedStringKey, CustomStringConvertible, TerminalOutputCase
        {
            case downloading
            case installingUpdate
            case cleaningUp

            public var patterns: [String]
            {
                switch self
                {
                case .downloading:
                    ["Fetching"]
                case .installingUpdate:
                    ["Reinstalling", "Installing", "Pouring"]
                case .cleaningUp:
                    ["cleanup"]
                }
            }

            public var description: String
            {
                switch self
                {
                case .downloading:
                    return String(localized: "update-packages.detail-stage.downloading")
                case .installingUpdate:
                    return String(localized: "update-packages.detail-stage.installing-update")
                case .cleaningUp:
                    return String(localized: "update-packages.detail-stage.cleanup")
                }
            }
        }

        public enum ErrorCases: TerminalOutputCase
        {
            /// Post-install scripts provided by the package failed
            case postInstallStepFailed

            /// Expects password
            case terminalRequired

            public var patterns: [String]
            {
                switch self
                {
                case .postInstallStepFailed:
                    ["post-install step did not complete successfully"]
                case .terminalRequired:
                    ["a terminal is required to read the password"]
                }
            }
        }

        public enum IgnoredCases: TerminalOutputCase
        {
            public var patterns: [String]
            {
                ["Caveats"]
            }
        }
    }
    
    public enum IndividualPackageUpdatingError: LocalizedError, Identifiable
    {
        public enum ImplementedError: LocalizedError
        {
            case postInstallStepFailed(rawOutput: String)
            case terminalRequired
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
