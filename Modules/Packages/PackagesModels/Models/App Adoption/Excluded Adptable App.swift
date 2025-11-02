//
//  Excluded Adptable App.swift
//  CorkModels
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation
import SwiftData
import CorkShared

@Model
public final class ExcludedAdoptableApp
{
    @Attribute(.unique) @Attribute(.spotlight)
    public var appExecutable: String
    
    public init(appExecutable: String)
    {
        self.appExecutable = appExecutable
    }
    
    public init(fromAdoptableApp app: BrewPackagesTracker.AdoptableApp)
    {
        self.appExecutable = app.appExecutable
    }
    
    @MainActor
    public func saveSelfToDatabase()
    {
        AppConstants.shared.modelContainer.mainContext.insert(self)
    }

    @MainActor
    public func deleteSelfFromDatabase()
    {
        let modelContext: ModelContext = AppConstants.shared.modelContainer.mainContext

        do
        {
            let descriptor = FetchDescriptor<ExcludedAdoptableApp>(
                predicate: #Predicate { $0.appExecutable == appExecutable }
            )

            if let existingPackage = try modelContext.fetch(descriptor).first
            {
                modelContext.delete(existingPackage)
            }
        }
        catch
        {
            AppConstants.shared.logger.error("Failed to fetch excluded adoptable app for deletion: \(error.localizedDescription)")
        }
    }
}
