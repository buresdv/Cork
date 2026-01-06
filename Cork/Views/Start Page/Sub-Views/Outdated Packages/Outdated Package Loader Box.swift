//
//  Outdated Package Loader Box.swift
//  Cork
//
//  Created by David Bureš on 05.04.2023.
//

import CorkShared
import SwiftUI
import CorkModels

struct OutdatedPackageLoaderBox: View
{
    @Environment(AppState.self) var appState: AppState
    
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker
    
    @Binding var errorOutReason: String?
    
    @State private var anotherOutdatedPackageRetrievalProcessIsAlreadyRunning: Bool = false
    
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
            guard anotherOutdatedPackageRetrievalProcessIsAlreadyRunning == false else
            {
                AppConstants.shared.logger.info("Another outdated package retrieval process is already running. Will not start another one.")
                
                return
            }
            
            anotherOutdatedPackageRetrievalProcessIsAlreadyRunning = true
            
            outdatedPackagesTracker.isCheckingForPackageUpdates = true

            AppConstants.shared.logger.info("Will start outdated package retrieval process")
            
            defer
            {
                withAnimation
                {
                    anotherOutdatedPackageRetrievalProcessIsAlreadyRunning = false
                    
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
