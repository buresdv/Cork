//
//  Updating Packages.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import SwiftUI

struct UpdatingPackagesStateView: View
{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker

    @ObservedObject var updateProcessDetailsStage: UpdatingProcessDetails

    @Binding var packageUpdatingStep: PackageUpdatingProcessSteps

    var body: some View
    {
        VStack(alignment: .leading, spacing: 3)
        {
            Text("update-packages.updating.updating")
            Text(updateProcessDetailsStage.currentStage.rawValue)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .task(priority: .userInitiated)
        {
            await updatePackages(updateProgressTracker: updateProgressTracker, appState: appState, outdatedPackageTracker: outdatedPackageTracker, detailStage: updateProcessDetailsStage)

            packageUpdatingStep = .updatingOutdatedPackageTracker
        }
    }
}
