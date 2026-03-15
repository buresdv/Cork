//
//  Reinstall Package.swift
//  Cork
//
//  Created by David Bureš on 04.04.2023.
//

import Foundation
import SwiftUI
import CorkShared
import CorkModels
import CorkTerminalFunctions
import FactoryKit

struct ReinstallCorruptedPackageView: View
{
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @InjectedObservable(\.appState) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @Environment(CachedDownloadsTracker.self) var cachedDownloadsTracker: CachedDownloadsTracker

    let corruptedPackageToReinstall: CorruptedPackage

    @State var corruptedPackageReinstallationStage: PackageReinstallationStage = .installing

    var body: some View
    {
        NavigationStack
        {
            switch corruptedPackageReinstallationStage
            {
            case .installing:
                ProgressView
                {
                    VStack(alignment: .leading)
                    {
                        Text("repair-package.repair-process-\(corruptedPackageToReinstall.name)")
                            
                        SubtitleText(text: "repair-package.repair-length.explanation")
                    }
                }
                .progressViewStyle(.linear)
                .padding()
                .toolbar
                {
                    ToolbarItem(placement: .cancellationAction)
                    {
                        Button
                        {
                            dismiss()
                        } label: {
                            Text("action.cancel")
                        }

                    }
                }
                .task
                {
                    let reinstallationResult: [TerminalOutput] = await shell(AppConstants.shared.brewExecutablePath, ["reinstall", corruptedPackageToReinstall.name])
                    AppConstants.shared.logger.debug("Reinstallation result:\nStandard output: \(reinstallationResult.standardOutputs, privacy: .public)\nStandard error:\(reinstallationResult.standardErrors, privacy: .public)")

                    corruptedPackageReinstallationStage = .finished
                }

            case .finished:
                DisappearableSheet
                {
                    ComplexWithIcon(systemName: "checkmark.seal")
                    {
                        HeadlineWithSubheadline(
                            headline: "repair-package.repairing-finished.headline-\(corruptedPackageToReinstall.name)",
                            subheadline: "repair-package.repairing-finished.subheadline",
                            alignment: .leading
                        )
                    }
                    .task
                    {
                        do
                        {
                            try await brewPackagesTracker.synchronizeInstalledPackages(cachedDownloadsTracker: cachedDownloadsTracker)
                        }
                        catch let synchronizationError
                        {
                            appState.showAlert(errorToShow: .couldNotSynchronizePackages(error: synchronizationError.localizedDescription))
                        }
                    }
                }
                .padding()
                .fixedSize()
            }
        }
    }
}
