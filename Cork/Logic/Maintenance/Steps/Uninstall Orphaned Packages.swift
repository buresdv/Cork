//
//  Uninstall Orphaned Packages.swift
//  Cork
//
//  Created by David Bureš on 16.02.2023.
//

import Foundation
import CorkShared
import CorkTerminalFunctions

enum OrphanUninstallationError: LocalizedError
{
    case unexpectedCommandOutput

    var errorDescription: String?
    {
        switch self
        {
        case .unexpectedCommandOutput:
            return String(localized: "error.maintenance.orphan-uninstallation.unexpected-terminal-output")
        }
    }
}

func uninstallOrphanedPackages() async throws -> TerminalOutput
{
    let commandResult: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["autoremove"])

    if !commandResult.standardOutput.contains("Autoremoving")
    {
        if commandResult.standardError.isEmpty
        {
            return commandResult
        }
        else
        {
            AppConstants.shared.logger.error("Unexpected orphan package removal output:\nStandard output: \(commandResult.standardOutput, privacy: .public)\nStandard error: \(commandResult.standardError, privacy: .public)")
            throw OrphanUninstallationError.unexpectedCommandOutput
        }
    }
    else
    {
        return commandResult
    }
}
