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
    @EnvironmentObject var appState: AppState
    
    @EnvironmentObject var brewData: BrewDataStorage
    
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    
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
            outdatedPackageTracker.isCheckingForPackageUpdates = true

            defer
            {
                withAnimation
                {
                    outdatedPackageTracker.isCheckingForPackageUpdates = false
                }
            }

            do
            {
                try await outdatedPackageTracker.getOutdatedPackages(brewData: brewData)
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
    }
}
