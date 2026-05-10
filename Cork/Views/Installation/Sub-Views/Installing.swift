//
//  Installing.swift
//  Cork
//
//  Created by David Bureš on 29.09.2023.
//

import CorkModels
import CorkShared
import CorkTerminalFunctions
import FactoryKit
import SwiftUI

struct InstallingPackageView: View
{
    @Environment(\.dismiss) var dismiss: DismissAction

    @InjectedObservable(\.appState) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    
    @Environment(PackageInstallationProcessStepTracker.self) var packageInstallationProcessStepTracker: PackageInstallationProcessStepTracker

    @Environment(CachedDownloadsTracker.self) var cachedDownloadsTracker: CachedDownloadsTracker

    let packageToInstall: MinimalHomebrewPackage

    @State var isShowingRealTimeOutput: Bool = false

    @State private var installationProgressTracker: InstallationProgressTracker

        init(packageToInstall: MinimalHomebrewPackage)
        {
            self.packageToInstall = packageToInstall
            self._installationProgressTracker = State(
                initialValue: InstallationProgressTracker(packageToInstall: packageToInstall)
            )
        }

    var body: some View
    {
        VStack(alignment: .leading)
        {
            ProgressView(installationProgressTracker.installProgress)
            
            switch installationProgressTracker.installStage
            {
            case .formula(let standardCases):
                Text(standardCases.stageDescription)
            case .cask(let standardCases):
                standardCases.view([packageToInstall])
            }
            
            installationProgressTracker.streamedOutputsDisplay
        }
        .task
        {
            do throws(InstallationProgressTracker.InstallationError)
            {
                try await installationProgressTracker.installPackage(
                    packageToInstall,
                    using: brewPackagesTracker,
                    cachedDownloadsTracker: cachedDownloadsTracker
                )
                
                packageInstallationProcessStepTracker.advanceStep(to: .finished)
            } catch let installationError
            {
                switch installationError
                {
                case .implemented(let implementedError):
                    packageInstallationProcessStepTracker.advanceStep(to: .erroredOut(withError: implementedError))
                case .unimplemented(let rawOutput):
                    packageInstallationProcessStepTracker.advanceStep(to:
                            .unexpectedTerminalOutput(rawOutput.containsErrors ? .containedErrors(rawOutput: rawOutput) : .didNotContainErrors(rawOutput: rawOutput))
                    )
                }
            }
        }
    }
}
