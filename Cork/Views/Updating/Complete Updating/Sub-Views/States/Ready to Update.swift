//
//  Ready to Update.swift
//  Cork
//
//  Created by David Bureš on 17.10.2023.
//

import SwiftUI

struct ReadyToUpdateStateView: View
{

    @EnvironmentObject var updateProgressTracker: UpdateProgressTracker
    @Binding var packageUpdatingStep: PackageUpdatingProcessSteps

    var body: some View
    {
        Text("update-packages.updating.ready")
            .onAppear
            {
                updateProgressTracker.updateProgress = 0
                packageUpdatingStep = .checkingForUpdates
            }
    }
}
