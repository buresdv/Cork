//
//  Top Packages.swift
//  Cork
//
//  Created by David Bureš on 21.09.2024.
//

import Foundation
import Testing

@Suite("Top Package Handling")
struct TestTopPackageHandling
{
    @Test("Retrieve Top Packages")
    func retrieveTopPackages() async throws
    {
        let mockedTopPackageTracker: TopPackagesTracker = await .init()
        
        await mockedTopPackageTracker.loadTopPackages(appState: .init())
        
        // MARK: - Confirm the tracker is not empty
        await #expect(!mockedTopPackageTracker.sortedTopFormulae.isEmpty)
        await #expect(!mockedTopPackageTracker.sortedTopCasks.isEmpty)
        
        await #expect(mockedTopPackageTracker.sortedTopFormulae.count > 2)
        await #expect(mockedTopPackageTracker.sortedTopCasks.count > 2)
    }
    
    @Test("Sort Top Packages")
    @MainActor
    func sortTopPackages() async throws
    {
        let initialUserDefaultsState = UserDefaults.standard.object(forKey: "sortTopPackagesBy")
        
        let mockedTopPackageTracker: TopPackagesTracker = .init()
        
        await mockedTopPackageTracker.loadTopPackages(appState: .init())
        
        // MARK: - Confirm the top packages are sorted correctly
        mockedTopPackageTracker.sortTopPackagesBy = .mostDownloads
        
        #expect(mockedTopPackageTracker.sortedTopFormulae.randomElement() != nil)
        
        #expect(mockedTopPackageTracker.sortedTopFormulae[0].downloadCount ?? 0 > mockedTopPackageTracker.sortedTopFormulae[1].downloadCount ?? 0)
        
        mockedTopPackageTracker.sortTopPackagesBy = .fewestDownloads
        
        #expect(mockedTopPackageTracker.sortedTopFormulae[0].downloadCount ?? 0 < mockedTopPackageTracker.sortedTopFormulae[1].downloadCount ?? 0)
        
        mockedTopPackageTracker.sortTopPackagesBy = .mostDownloads
    }
}
