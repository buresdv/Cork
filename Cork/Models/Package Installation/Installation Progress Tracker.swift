//
//  Installation Progress Tracker.swift
//  Cork
//
//  Created by David Bureš on 22.02.2023.
//

import Foundation

class InstallationProgressTracker: ObservableObject
{
    @Published var packageBeingCurrentlyInstalled: String = ""

    @Published var packagesBeingInstalled: [PackageInProgressOfBeingInstalled] = .init()
    
    @Published var numberOfPackageDependencies: Int = 0
    @Published var numberInLineOfPackageCurrentlyBeingFetched: Int = 0
    @Published var numberInLineOfPackageCurrentlyBeingInstalled: Int = 0

    @MainActor
    func installPackage(using brewData: BrewDataStorage) async throws -> TerminalOutput {
        try await Cork.installPackage(installationProgressTracker: self, brewData: brewData)
    }
}
