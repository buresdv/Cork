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

    @State var corruptedPackageToReinstall: String

    @State var corruptedPackageReinstallationStage: PackageReinstallationStage = .installing

    var body: some View
    {
        switch corruptedPackageReinstallationStage
        {
        case .installing:
            ProgressView
            {
                Text("repair-package.repair-process-\(corruptedPackageToReinstall)")
            }
            .progressViewStyle(.linear)
            .padding()
            .task(priority: .userInitiated)
            {
                let reinstallationResult: TerminalOutput = await shell(AppConstants.brewExecutablePath, ["reinstall", corruptedPackageToReinstall])
                AppConstants.logger.debug("Reinstallation result:\nStandard output: \(reinstallationResult.standardOutput, privacy: .public)\nStandard error:\(reinstallationResult.standardError, privacy: .public)")

                corruptedPackageReinstallationStage = .finished
            }

        case .finished:
            DisappearableSheet(isShowingSheet: $appState.isShowingPackageReinstallationSheet)
            {
                ComplexWithIcon(systemName: "checkmark.seal")
                {
                    HeadlineWithSubheadline(
                        headline: "repair-package.repairing-finished.headline-\(corruptedPackageToReinstall)",
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
