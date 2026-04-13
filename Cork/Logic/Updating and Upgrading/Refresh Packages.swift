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
        enum StandardCases: TerminalOutputCase
        {
            case updatingHomebrew
            case alreadyUpToDate
            
            var patterns: [String]
            {
                switch self {
                case .updatingHomebrew:
                    ["==> Updating Homebrew"]
                case .alreadyUpToDate:
                    ["Already up-to-date"]
                }
            }
        }
        
        enum ErrorCases: TerminalOutputCase
        {
            case error
            
            var patterns: [String]
            {
                switch self {
                case .error:
                    ["Error: "]
                }
            }
        }
        
        enum IgnorableCases: TerminalOutputCase
        {
            var patterns: [String]
            {
                ["Another active Homebrew update process is already in progress", "No checksum defined"]
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
            if showRealTimeTerminalOutputs
            {
                updateProgressTracker.realTimeOutput.append(RealTimeTerminalLine(line: output))
            }
            
            output.match(as: PackageRefreshMatcher.self)
            { matchedStandardCase in
                switch matchedStandardCase
                {
                case .updatingHomebrew:
                    
                }
            } onErrorOutput: { matchedErrorCase in
                <#code#>
            } onUnimplementedOutput: { unimplementedOutput in
                <#code#>
            }

            
            switch output
            {
            case .standardOutput(let outputLine):
                AppConstants.shared.logger.log("Update function output: \(outputLine, privacy: .public)")

                if showRealTimeTerminalOutputs
                {
                    updateProgressTracker.realTimeOutput.append(RealTimeTerminalLine(line: outputLine))
                }

                updateProgressTracker.updateProgress = updateProgressTracker.updateProgress + 0.1

                if self.allDisplayableOutdatedPackages.isEmpty
                {
                    if outputLine.starts(with: "Already up-to-date")
                    {
                        AppConstants.shared.logger.info("Inside update function: No updates available")
                        return .noUpdatesAvailable
                    }
                }

            case .standardError(let errorLine):

                if showRealTimeTerminalOutputs
                {
                    updateProgressTracker.realTimeOutput.append(RealTimeTerminalLine(line: errorLine))
                }

                if errorLine.starts(with: "Another active Homebrew update process is already in progress") || errorLine == "Error: " || errorLine.contains("Updated [0-9]+ tap") || errorLine == "Already up-to-date" || errorLine.contains("No checksum defined")
                {
                    updateProgressTracker.updateProgress = updateProgressTracker.updateProgress + 0.1
                    AppConstants.shared.logger.log("Ignorable update function error: \(errorLine, privacy: .public)")

                    return .noUpdatesAvailable
                }
                else
                {
                    if !errorLine.contains("==> Updating Homebrew...")
                    {
                        AppConstants.shared.logger.warning("Update function error: \(errorLine, privacy: .public)")
                        updateProgressTracker.errors.append("Update error: \(errorLine)")
                    }
                }
            }
        }
        updateProgressTracker.updateProgress = Float(10) / Float(2)

        return .updatesAvailable
    }
}
