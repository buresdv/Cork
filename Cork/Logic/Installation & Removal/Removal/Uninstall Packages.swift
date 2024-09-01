//
//  Uninstall Packages.swift
//  Cork
//
//  Created by David Bureš on 05.02.2023.
//

import Foundation
import SwiftUI

extension BrewDataStorage
{
    @MainActor
    func uninstallSelectedPackage(
        package: BrewPackage,
        appState: AppState,
        outdatedPackageTracker: OutdatedPackageTracker,
        shouldRemoveAllAssociatedFiles: Bool,
        shouldApplyUninstallSpinnerToRelevantItemInSidebar: Bool = false
    ) async throws
    {
        /// Store the old navigation selection to see if it got updated in the middle of switching
        let oldNavigationSelectionID: UUID? = appState.navigationSelection

        if shouldApplyUninstallSpinnerToRelevantItemInSidebar
        {
            if package.type == .formula
            {
                installedFormulae = Set(installedFormulae.map
                { formula in
                    var copyFormula: BrewPackage = formula
                    if copyFormula.name == package.name
                    {
                        copyFormula.changeBeingModifiedStatus()
                    }
                    return copyFormula
                })
            }
            else
            {
                installedCasks = Set(installedCasks.map
                { cask in
                    var copyCask: BrewPackage = cask
                    if copyCask.name == package.name
                    {
                        copyCask.changeBeingModifiedStatus()
                    }
                    return copyCask
                })
            }
        }
        else
        {
            appState.isShowingUninstallationProgressView = true
        }

        AppConstants.logger.info("Will try to remove package \(package.name, privacy: .auto)")
        var uninstallCommandOutput: TerminalOutput

        if !shouldRemoveAllAssociatedFiles
        {
            uninstallCommandOutput = await shell(AppConstants.brewExecutablePath, ["uninstall", package.name])
        }
        else
        {
            uninstallCommandOutput = await shell(AppConstants.brewExecutablePath, ["uninstall", "--zap", package.name])
        }

        AppConstants.logger.warning("Uninstall process Standard error: \(uninstallCommandOutput.standardError)")

        if uninstallCommandOutput.standardError.contains("because it is required by")
        {
            AppConstants.logger.warning("Could not uninstall this package because it's a dependency")

            /// If the uninstallation failed, change the status back to "not being modified"
            resetPackageState(package: package)

            do
            {
                var dependencyName: String = try uninstallCommandOutput.standardError.regexMatch("(?<=required by ).*?(?=, which)")

                appState.showAlert(errorToShow: .uninstallationNotPossibleDueToDependency(packageThatTheUserIsTryingToUninstall: package, offendingDependencyProhibitingUninstallation: dependencyName))

                AppConstants.logger.warning("Name of offending dependency: \(dependencyName, privacy: .public)")
            }
            catch let regexError as NSError
            {
                AppConstants.logger.error("Failed to extract dependency name from output: \(regexError, privacy: .public)")
                throw RegexError.regexFunctionCouldNotMatchAnything
            }
        }
        else if uninstallCommandOutput.standardError.contains("sudo: a terminal is required to read the password")
        {
            // TODO: So far, this only stops the package from being removed from the tracker. Implement a tutorial on how to uninstall the package

            AppConstants.logger.error("Could not uninstall this package because sudo is required")

            appState.packageTryingToBeUninstalledWithSudo = package
            appState.isShowingSudoRequiredForUninstallSheet = true

            resetPackageState(package: package)
        }
        else
        {
            AppConstants.logger.info("Uninstalling can proceed")

            switch package.type
            {
            case .formula:
                withAnimation
                {
                    self.removeFormulaFromTracker(withName: package.name)
                }

            case .cask:
                withAnimation
                {
                    self.removeCaskFromTracker(withName: package.name)
                }
            }

            if appState.navigationSelection != nil
            {
                /// Switch to the status page only if the user didn't open another details window in the middle of the uninstall process
                if oldNavigationSelectionID == appState.navigationSelection
                {
                    appState.navigationSelection = nil
                }
            }
        }

        appState.isShowingUninstallationProgressView = false

        AppConstants.logger.info("Package uninstallation process output:\nStandard output: \(uninstallCommandOutput.standardOutput, privacy: .public)\nStandard error: \(uninstallCommandOutput.standardError, privacy: .public)")

        /// If the user removed a package that was outdated, remove it from the outdated package tracker
        Task
        {
            if let index = outdatedPackageTracker.displayableOutdatedPackages.firstIndex(where: { $0.package.name == package.name })
            {
                outdatedPackageTracker.outdatedPackages.remove(at: index)
            }
        }
    }

    @MainActor
    private func resetPackageState(package: BrewPackage)
    {
        if package.type == .formula
        {
            installedFormulae = Set(installedFormulae.map
            { formula in
                var copyFormula: BrewPackage = formula
                if copyFormula.name == package.name, copyFormula.isBeingModified == true
                {
                    copyFormula.changeBeingModifiedStatus()
                }
                return copyFormula
            })
        }
        else
        {
            installedCasks = Set(installedCasks.map
            { cask in
                var copyCask: BrewPackage = cask
                if copyCask.name == package.name, copyCask.isBeingModified == true
                {
                    copyCask.changeBeingModifiedStatus()
                }
                return copyCask
            })
        }
    }
}
