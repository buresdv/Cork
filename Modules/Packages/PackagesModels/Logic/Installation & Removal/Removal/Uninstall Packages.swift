//
//  Uninstall Packages.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import CorkShared
import Foundation
import SwiftUI
import CorkTerminalFunctions

public extension BrewPackagesTracker
{
    @MainActor
    func uninstallSelectedPackage(
        package: BrewPackage,
        cachedDownloadsTracker: CachedDownloadsTracker,
        appState: AppState,
        shouldRemoveAllAssociatedFiles: Bool
    ) async throws
    {

        self.updatePackageInPlace(package)
        { package in
            package.changeBeingModifiedStatus()
        }
        
        defer
        {
            AppConstants.shared.logger.debug("Would reset state now")
            self.updatePackageInPlace(package)
            { package in
                package.isBeingModified = false
            }
        }

        AppConstants.shared.logger.info("Will try to remove package \(package.name, privacy: .auto)")
        var uninstallCommandOutput: TerminalOutput

        if !shouldRemoveAllAssociatedFiles
        {
            uninstallCommandOutput = await shell(AppConstants.shared.brewExecutablePath, ["uninstall", package.name])
        }
        else
        {
            uninstallCommandOutput = await shell(AppConstants.shared.brewExecutablePath, ["uninstall", "--zap", package.name])
        }

        AppConstants.shared.logger.warning("Uninstall process Standard error: \(uninstallCommandOutput.standardError)")

        if uninstallCommandOutput.standardError.contains("because it is required by")
        {
            AppConstants.shared.logger.warning("Could not uninstall this package because it's a dependency")

            do
            {
                let dependencyName: String = try uninstallCommandOutput.standardError.regexMatch("(?<=required by ).*?(?=, which)")

                appState.showAlert(errorToShow: .uninstallationNotPossibleDueToDependency(packageThatTheUserIsTryingToUninstall: package, offendingDependencyProhibitingUninstallation: dependencyName))

                AppConstants.shared.logger.warning("Name of offending dependency: \(dependencyName, privacy: .public)")
            }
            catch let regexError as NSError
            {
                AppConstants.shared.logger.error("Failed to extract dependency name from output: \(regexError, privacy: .public)")
                throw RegexError.regexFunctionCouldNotMatchAnything
            }
        }
        else if uninstallCommandOutput.standardError.contains("sudo: a terminal is required to read the password")
        {
            // TODO: So far, this only stops the package from being removed from the tracker. Implement a tutorial on how to uninstall the package

            AppConstants.shared.logger.error("Could not uninstall this package because sudo is required")

            appState.packageTryingToBeUninstalledWithSudo = package
            appState.showSheet(ofType: .sudoRequiredForPackageRemoval)
            
        }
        else
        {
            do
            {
                try await self.synchronizeInstalledPackages(cachedDownloadsTracker: cachedDownloadsTracker)
                
                if !uninstallCommandOutput.standardError.isEmpty && uninstallCommandOutput.standardError.contains("Error:")
                {
                    AppConstants.shared.logger.error("There was a serious uninstall error: \(uninstallCommandOutput.standardError)")
                    
                    appState.showAlert(errorToShow: .fatalPackageUninstallationError(packageName: package.name, errorDetails: uninstallCommandOutput.standardError))
                }
                else
                {
                    AppConstants.shared.logger.info("Uninstalling can proceed")
                }
            }
            catch let synchronizationError
            {
                appState.showAlert(errorToShow: .couldNotSynchronizePackages(error: synchronizationError.localizedDescription))
            }
        }

        appState.isShowingUninstallationProgressView = false

        AppConstants.shared.logger.info("Package uninstallation process output:\nStandard output: \(uninstallCommandOutput.standardOutput, privacy: .public)\nStandard error: \(uninstallCommandOutput.standardError, privacy: .public)")

        /// If the user removed a package that was outdated, remove it from the outdated package tracker
        if let index = outdatedPackagesTracker.outdatedPackages.firstIndex(where: { $0.package.name == package.name })
        {
            outdatedPackagesTracker.outdatedPackages.remove(at: index)
        }
    }
}
