//
//  Update Some Packages View.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import SwiftUI

struct UpdateSomePackagesView: View
{
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    @Binding var isShowingSheet: Bool

    @State private var packageUpdatingStage: PackageUpdatingStage = .updating
    @State private var packageBeingCurrentlyUpdated: BrewPackage?

    var selectedPackages: [OutdatedPackage]
    {
        return outdatedPackageTracker.outdatedPackages.filter { $0.isMarkedForUpdating }
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            switch packageUpdatingStage
            {
            case .updating:
                ProgressView(value: 1, total: Double(outdatedPackageTracker.outdatedPackages.count))
                {
                    Text("Ahoj")
                }
            case .finished:
                DisappearableSheet(isShowingSheet: $isShowingSheet)
                {
                    ComplexWithIcon(systemName: "checkmark.seal")
                    {
                        SheetWithTitle(title: "update-packages.incremental.finished")
                        {
                            Text("update-packages.finished.description")
                        }
                    }
                }

            case .erroredOut:
                Text("Errors")
            case .noUpdatesAvailable:
                Text("update-packages.incremental.impossible-case")
            }
        }
        .padding()
    }
}
