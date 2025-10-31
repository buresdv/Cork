//
//  Get Names of Pinned Packages.swift
//  CorkPackagesModels
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation
import CorkShared
import CorkTerminalFunctions

public extension BrewPackagesTracker
{
    /// Get the names of tagged packages as set, for fas comparing
    ///
    /// Has to be `async`; if it fails, use the slower command to determine pinned packages
    func getNamesOfPinnedPackages(atPinnedPackagesPath folderPath: URL) async -> Set<String>
    {
        do
        { /// Try to read the pinned packages directly from disk
            let contentOfFolder: [URL] = try FileManager.default.contentsOfDirectory(at: folderPath, includingPropertiesForKeys: [.isSymbolicLinkKey])
            
            let namesOfPinnedPackages: [String] = contentOfFolder.map({ $0.lastPathComponent })
            
            AppConstants.shared.logger.debug("Retrieved a list of pinned package names from disk: \(namesOfPinnedPackages)")
            
            return Set(namesOfPinnedPackages)
        }
        catch
        { /// If the pinned packages cannot be read for some reason, use the built-in command to get them
            let rawOutput: String = await shell(AppConstants.shared.brewExecutablePath, ["list", "--pinned"]).standardOutput
            
            AppConstants.shared.logger.debug("Retrieved a list of pinned package names from command. Raw output: \(rawOutput)")
            
            let namesOfPinnedPackages: [String] = rawOutput.components(separatedBy: "\n")
            
            return Set(namesOfPinnedPackages)
        }
    }
}
