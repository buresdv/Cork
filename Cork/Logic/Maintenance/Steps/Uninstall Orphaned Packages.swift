//
//  Uninstall Orphaned Packages.swift
//  Cork
//
//  Created by David Bureš on 16.02.2023.
//

import Foundation

enum OrphanUninstallationError: Error
{
    case standardErrorNotEmpty
}

func uninstallOrphanedPackages() async throws -> TerminalOutput
{
    async let commandResult: TerminalOutput = await shell("/opt/homebrew/bin/brew", ["autoremove"])
    
    if await commandResult.standardError != ""
    {
        print("ERROR: \(await commandResult.standardError)")
        throw OrphanUninstallationError.standardErrorNotEmpty
    }
    else
    {
        return await commandResult
    }
}
