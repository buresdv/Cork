//
//  Mass Adoption Stage - Ready.swift
//  Cork
//
//  Created by David Bureš - P on 07.10.2025.
//

import CorkShared
import SwiftUI
import CorkModels

struct MassAdoptionStage_Adopting: View
{
    @Environment(MassAppAdoptionView.MassAppAdoptionTacker.self) var massAppAdoptionTracker: MassAppAdoptionView.MassAppAdoptionTacker
    
    let appsToAdopt: [BrewPackagesTracker.AdoptableApp]
    
    @State private var currentAdoptionIndex: Double = 0

    var body: some View
    {
        ProgressView(value: currentAdoptionIndex, total: Double(appsToAdopt.count))
        {
            Text("app-adoption.currently-being-adopted.\(massAppAdoptionTracker.appCurrentlyBeingAdopted.appExecutable)")
        }
        .progressViewStyle(.linear)
        .task
        {
            for appToAdopt in appsToAdopt
            {
                AppConstants.shared.logger.info("Will start adoption process for \(appToAdopt.selectedAdoptionCandidate.caskName)")

                await massAppAdoptionTracker.adoptNextApp(appToAdopt: appToAdopt)
                
                currentAdoptionIndex += 1
            }
            
            if massAppAdoptionTracker.unsuccessfullyAdoptedApps.isEmpty
            {
                AppConstants.shared.logger.info("All selected apps were adopted successfully!")
                
                massAppAdoptionTracker.massAdoptionStage = .finished(result: .success)
            }
            else if !massAppAdoptionTracker.unsuccessfullyAdoptedApps.isEmpty && !massAppAdoptionTracker.successfullyAdoptedApps.isEmpty
            {
                AppConstants.shared.logger.warning("Some selected apps were adoptes successfully, some unsuccessfully")
                
                massAppAdoptionTracker.massAdoptionStage = .finished(result: .someSuccessSomeFailure)
            }
            else
            {
                AppConstants.shared.logger.error("No selected apps were adopted successfully")
                
                massAppAdoptionTracker.massAdoptionStage = .finished(result: .failure)
            }
        }
        .onDisappear
        {
            AppConstants.shared.logger.info("Cancelled the app adoption - will also cancel the app adoption process")
            
            massAppAdoptionTracker.cancel()
        }
    }
}
