//
//  Excluded Adoptable Package.swift
//  CorkShared
//
//  Created by David Bureš - P on 28.10.2025.
//

import Foundation
import SwiftData

@Model
public final class ExcludedAdoptableApp: Sendable
{
    @Attribute(.unique) @Attribute(.spotlight)
    public var appExecutable: String
    
    public init(appExecutable: String)
    {
        self.appExecutable = appExecutable
    }
    
    @MainActor
    public func saveSelfToDatabase()
    {
        AppConstants.shared.logger.debug("Will try to insert \(self.appExecutable) to excluded app database")
        AppConstants.shared.modelContainer.mainContext.insert(self)
        
        try? AppConstants.shared.modelContainer.mainContext.save()
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
                AppConstants.shared.logger.info("Found this package in database")
                
                modelContext.delete(existingPackage)
                
                try? AppConstants.shared.modelContainer.mainContext.save()
            } else {
                AppConstants.shared.logger.error("Couldn't find this package in database")
            }
            
        }
        catch
        {
            AppConstants.shared.logger.error("Failed to fetch excluded adoptable app for deletion: \(error.localizedDescription)")
        }
    }
}
