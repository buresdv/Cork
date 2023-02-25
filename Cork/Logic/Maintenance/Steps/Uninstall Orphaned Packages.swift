//
//  Uninstall Orphaned Packages.swift
//  Cork
//
//  Created by David Bureš on 16.02.2023.
//

import Foundation

enum OrphanUninstallationError: Error
{
    case unexpectedCommandOutput
}

func uninstallOrphanedPackages() async throws -> TerminalOutput
{
    let commandResult: TerminalOutput = await shell("/opt/homebrew/bin/brew", ["autoremove"])
    
    if !commandResult.standardOutput.contains("Autoremoving")
    {
        throw OrphanUninstallationError.unexpectedCommandOutput
    }
    else
    {
        return commandResult
    }
}
