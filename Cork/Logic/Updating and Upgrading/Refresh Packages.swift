//
//  Update Packages.swift
//  Cork
//
//  Created by David Bureš on 09.03.2023.
//

import Foundation
import SwiftUI
import CorkShared
import CorkTerminalFunctions
import CorkModels
import Defaults

public extension OutdatedPackagesTracker
{
    enum PackageUpdateAvailability: CustomStringConvertible
    {
        case updatesAvailable, noUpdatesAvailable

        public var description: String
        {
            switch self
            {
            case .updatesAvailable: return "Updates available"
            case .noUpdatesAvailable: return "No updates available"
            }
        }
    }
    
    enum PackageRefreshMatcher: TerminalOutputMatchable
    {
        public enum StandardCases: TerminalOutputCase
        {
            case alreadyUpToDate
            case other

            public var patterns: [String]
            {
                switch self
                {
                case .alreadyUpToDate:
                    ["Already up-to-date"]
                case .other:
                    // Catch-all — any unrecognised stdout still increments progress
                    [""]
                }
            }
        }

        public enum ErrorCases: TerminalOutputCase
        {
            case anotherUpdateInProgress
            case emptyError
            case updatedTap
            case alreadyUpToDate
            case noChecksumDefined

            public var patterns: [String]
            {
                switch self
                {
                case .anotherUpdateInProgress:
                    ["Another active Homebrew update process is already in progress"]
                case .emptyError:
                    ["Error: "]
                case .updatedTap:
                    ["Updated"]
                case .alreadyUpToDate:
                    ["Already up-to-date"]
                case .noChecksumDefined:
                    ["No checksum defined"]
                }
            }
        }

        public enum IgnoredCases: TerminalOutputCase
        {
            case updatingHomebrew

            public var patterns: [String]
            {
                switch self
                {
                case .updatingHomebrew:
                    ["==> Updating Homebrew..."]
                }
            }
        }
    }
    
    @MainActor
    func refreshPackages(
        updateProgressTracker: UpdateProgressTracker
    ) async -> PackageUpdateAvailability
    {
        let showRealTimeTerminalOutputs: Bool = Defaults[.showRealTimeTerminalOutputOfOperations]

        for await output in shell(AppConstants.shared.brewExecutablePath, ["update"])
        {
            AppConstants.shared.logger.log("Update function output: \(output.description, privacy: .public)")

            if showRealTimeTerminalOutputs
            {
                updateProgressTracker.insertOutput(output)
            }

            if let result: PackageUpdateAvailability = output.match(as: PackageRefreshMatcher.self,
                onStandardOutput: { matched in
                    switch matched
                    {
                    case .alreadyUpToDate:
                        guard self.allDisplayableOutdatedPackages.isEmpty
                        else { return nil }

                        AppConstants.shared.logger.info("Inside update function: No updates available")
                        return .noUpdatesAvailable

                    case .other:
                        return nil
                    }
                },
                onErrorOutput: { matched in
                    return .noUpdatesAvailable
                },
                onUnimplementedOutput: { unimplemented in
                    AppConstants.shared.logger.warning("Update function error: \(unimplemented.description, privacy: .public)")
                updateProgressTracker.insertOutput(unimplemented)
                    return nil
                }
            )
            {
                return result
            }
        }
        return .updatesAvailable
    }
}
