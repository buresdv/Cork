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
                Text(standardCases.stageDescription)
            }
        }
        .task
        {
            do
            {}
        }
    }
}
