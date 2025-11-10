//
//  Adopting Already Installed Cask.swift
//  Cork
//
//  Created by David Bureš - P on 16.07.2025.
//

import CorkShared
import SwiftUI
import CorkModels
import CorkTerminalFunctions

struct AdoptingAlreadyInstalledCaskView: View
{
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    
    @Bindable var installationProgressTracker: InstallationProgressTracker

    private var caskToAdopt: BrewPackage {
        installationProgressTracker.packageBeingInstalled.package
    }
    
    private enum AdoptionStep
    {
        case working
        case finished
        case failed
    }

    @State private var adoptionStep: AdoptionStep = .working

    var body: some View
    {
        switch adoptionStep
        {
        case .working:
            ProgressView("adopt-cask.in-progress.\(caskToAdopt.name)")
                .progressViewStyle(.linear)
                .task
                {
                    AppConstants.shared.logger.debug("Started adoption process for cask \(caskToAdopt.name)")

                    let adoptionResult: TerminalOutput = await shell(AppConstants.shared.brewExecutablePath, ["install", "--cask", "--adopt", caskToAdopt.name])

                    AppConstants.shared.logger.debug("""
                    Finished adoption process for cask \(caskToAdopt.name) with this result:
                    Output: \(adoptionResult.standardOutput)
                    Error: \(adoptionResult.standardError)
                    """)
                    
                    if adoptionResult.standardOutput.contains("was successfully installed")
                    {
                        AppConstants.shared.logger.info("Adoption frocess for cask \(caskToAdopt.name) was successful")
                        
                        self.adoptionStep = .finished
                    }
                    else
                    {
                        AppConstants.shared.logger.error("Adoption frocess for cask \(caskToAdopt.name) failed")
                        self.adoptionStep = .failed
                    }
                }
        case .finished:
            DisappearableSheet
            {
                ComplexWithIcon(systemName: "checkmark.seal")
                {
                    HeadlineWithSubheadline(
                        headline: "adopt-cask.finished-\(caskToAdopt.name)",
                        subheadline: "adopt-cask.finished.description",
                        alignment: .leading
                    )
                }
            }
        case .failed:
            ComplexWithIcon(systemName: "exclamationmark.triangle")
            {
                HeadlineWithSubheadline(
                    headline: "adopt-cask.fatal-error-\(caskToAdopt.name)",
                    subheadline: "add-package.fatal-error.description",
                    alignment: .leading
                )
            }
        }
    }
}
