//
//  Reinstall Package.swift
//  Cork
//
//  Created by David Bureš on 04.04.2023.
//

import Foundation
import SwiftUI

struct ReinstallCorruptedPackageView: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var brewData: BrewDataStorage

    let corruptedPackageToReinstall: CorruptedPackage

    @State var corruptedPackageReinstallationStage: PackageReinstallationStage = .installing

    var body: some View
    {
        switch corruptedPackageReinstallationStage
        {
        case .installing:
            ProgressView
            {
                Text("repair-package.repair-process-\(corruptedPackageToReinstall.name)")
            }
            .progressViewStyle(.linear)
            .padding()
            .task(priority: .userInitiated)
            {
                let reinstallationResult: TerminalOutput = await shell(AppConstants.brewExecutablePath, ["reinstall", corruptedPackageToReinstall.name])
                AppConstants.logger.debug("Reinstallation result:\nStandard output: \(reinstallationResult.standardOutput, privacy: .public)\nStandard error:\(reinstallationResult.standardError, privacy: .public)")

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
                .task(priority: .background)
                {
                    await synchronizeInstalledPackages(brewData: brewData)
                }
            }
            .padding()
            .fixedSize()
        }
    }
}
