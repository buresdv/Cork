//
//  Mass App Adoption View.swift
//  Cork
//
//  Created by David Bureš - P on 07.10.2025.
//

import SwiftUI

typealias AdoptionProcessResult = Result<BrewPackagesTracker.AdoptableApp, MassAppAdoptionView.AdoptionAttemptFailure>

struct MassAppAdoptionView: View
{
    @Observable
    final class MassAppAdoptionTacker
    {
        @ObservationIgnored
        var adoptionProcess: Process?

        var outputLines: [RealTimeTerminalLine] = .init()
        
        var massAdoptionStage: MassAdoptionStage = .adopting
        
        private(set) var appCurrentlyBeingAdopted: BrewPackagesTracker.AdoptableApp
        private(set) var currentAdoptionIndex: Int
        
        private(set) var appAdoptionResults: [AdoptionProcessResult] = .init()
        
        var successfullyAdoptedApps: [BrewPackagesTracker.AdoptableApp]
        {
            return appAdoptionResults.compactMap
            { rawResult in
                if case .success(let success) = rawResult {
                    return success
                }
                else
                {
                    return nil
                }
            }
        }
        
        var unsuccessfullyAdoptedApps: [MassAppAdoptionView.AdoptionAttemptFailure]
        {
            return appAdoptionResults.compactMap
            { rawResult in
                if case .failure(let failure) = rawResult {
                    return failure
                }
                else
                {
                    return nil
                }
            }
        }

        init(appsToAdopt: [BrewPackagesTracker.AdoptableApp])
        {
            self.appCurrentlyBeingAdopted = appsToAdopt.first!
            self.currentAdoptionIndex = 0
        }
        
        deinit
        {
            cancel()
        }

        @MainActor
        func adoptNextApp(appToAdopt: BrewPackagesTracker.AdoptableApp) async
        {
            self.appCurrentlyBeingAdopted = appToAdopt
            self.currentAdoptionIndex += 1
            
            self.appAdoptionResults.append(await self.adoptApp(appToAdopt))
        }
        
        @discardableResult
        func cancel() -> Bool
        {
            guard let adoptionProcess else { return false }
            adoptionProcess.terminate()
            self.adoptionProcess = nil
            return true
        }
    }
    
    @Environment(\.dismiss) var dismiss: DismissAction
    
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    @Environment(CachedDownloadsTracker.self) var cachedDownloadsTracker: CachedDownloadsTracker
    
    let appsToAdopt: [BrewPackagesTracker.AdoptableApp]
    
    @State private var massAdoptionTracker: MassAppAdoptionTacker
    
    init(appsToAdopt: [BrewPackagesTracker.AdoptableApp])
    {
        self.appsToAdopt = appsToAdopt
        self.massAdoptionTracker = .init(appsToAdopt: appsToAdopt)
    }
    
    enum AdoptionAttemptFailure: Identifiable, Error
    {
        case failedWithError(failedAdoptionCandidate: BrewPackagesTracker.AdoptableApp, error: String)
        
        var id: UUID
        {
            switch self {
            case .failedWithError(let failedAdoptionCandidate, let error):
                return failedAdoptionCandidate.id
            }
        }
    }

    enum MassAdoptionStage
    {
        case adopting, finished(result: AdoptionResult)

        enum AdoptionResult
        {
            case success
            case someSuccessSomeFailure
            case failure
        }

        var isDismissable: Bool
        {
            switch self
            {
            case .adopting:
                return true
            case .finished:
                return true
            }
        }
    }

    var body: some View
    {
        NavigationStack
        {
            SheetTemplate(isShowingTitle: true)
            {
                switch massAdoptionTracker.massAdoptionStage
                {
                case .adopting:
                    MassAdoptionStage_Adopting(appsToAdopt: appsToAdopt)
                case .finished(let result):
                    switch result
                    {
                    case .success:
                        MassAdoptionStage_Success()
                    case .someSuccessSomeFailure:
                        MassAdoptionStage_SomeSuccessSomeFailure()
                    case .failure:
                        MassAdoptionStage_Failure()
                    }
                }
            }
            .navigationTitle("mass-adoption.title")
            .toolbar
            {
                if massAdoptionTracker.massAdoptionStage.isDismissable
                {
                    ToolbarItem(placement: .cancellationAction)
                    {
                        DismissSheetButton(dismiss: _dismiss)
                    }
                }
            }
        }
        .environment(massAdoptionTracker)
        .onDisappear
        {
            Task
            {
                try? await brewPackagesTracker.synchronizeInstalledPackages(cachedDownloadsTracker: cachedDownloadsTracker)
            }
        }
    }
}
