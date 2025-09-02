//
//  Outdated Package Loader Box.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import CorkShared
import SwiftUI

struct OutdatedPackageLoaderBox: View
{
    @Environment(AppState.self) var appState
    
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker
    
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker
    
    @Binding var errorOutReason: String?
    
    var body: some View
    {
        Grid
        {
            GridRow(alignment: .firstTextBaseline)
            {
                HStack(alignment: .center, spacing: 15)
                {
                    ProgressView()

                    Text("start-page.updates.loading")
                }
            }
        }
        .task
        {
            outdatedPackagesTracker.isCheckingForPackageUpdates = true

            defer
            {
                withAnimation
                {
                    outdatedPackagesTracker.isCheckingForPackageUpdates = false
                }
            }

            do
            {
                try await outdatedPackagesTracker.getOutdatedPackages(brewPackagesTracker: brewPackagesTracker)
            }
            catch let outdatedPackageRetrievalError as OutdatedPackageRetrievalError
            {
                switch outdatedPackageRetrievalError
                {
                case .homeNotSet:
                    appState.showAlert(errorToShow: .homePathNotSet)
                default:
                    AppConstants.shared.logger.error("Could not decode outdated package command output: \(outdatedPackageRetrievalError.localizedDescription)")
                    errorOutReason = outdatedPackageRetrievalError.localizedDescription
                }
            }
            catch
            {
                AppConstants.shared.logger.error("Unspecified error while pulling package updates")
            }
        }
        .transition(.push(from: .top))
        .accessibilityLabel("accessibility.label.outdated-packages-box.loading")
    }
}
