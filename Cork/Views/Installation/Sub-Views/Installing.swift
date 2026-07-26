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

    @Binding var installationProgressTracker: InstallationProgressTracker

    init(packageToInstall: MinimalHomebrewPackage, installationProgressTracker: Binding<InstallationProgressTracker>)
    {
        self.packageToInstall = packageToInstall
        self._installationProgressTracker = installationProgressTracker
    }

    var body: some View
    {
        VStack(alignment: .leading)
        {
            ProgressView(installationProgressTracker.installProgress)

            installationProgressTracker.streamedOutputsDisplay
        }
        .task
        {
            do throws
            {
                try await installationProgressTracker.installPackage(
                    packageToInstall,
                    using: brewPackagesTracker,
                    cachedDownloadsTracker: cachedDownloadsTracker
                )

                packageInstallationProcessStepTracker.advanceStep(to: .finished)
            }
            catch let installationError as InstallationProgressTracker.InstallationError
            {
                switch installationError
                {
                case .implemented(let implementedError):
                    packageInstallationProcessStepTracker.advanceStep(to: .erroredOut(
                        package: packageToInstall,
                        withError: implementedError
                    ))
                case .unimplemented(let rawOutput):
                    packageInstallationProcessStepTracker.advanceStep(to:
                        .unexpectedTerminalOutput(rawOutput.containsErrors ? .containedErrors(rawOutput: rawOutput) : .didNotContainErrors(rawOutput: rawOutput))
                    )
                }
            }
            catch let unexpectedError
            { // TODO: There was an unexpected error, so handle that differently
            }
        }
    }
}

