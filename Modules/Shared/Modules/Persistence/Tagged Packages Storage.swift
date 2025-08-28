//
//  Tagged Packages Storage.swift
//  Cork
//
//  Created by David Bureš - P on 18.05.2025.
//

import Foundation
import SwiftData

@Model
public final class SavedTaggedPackage
{
    /// Full names of packages, which includes the Homebrew version
    @Attribute(.unique) @Attribute(.spotlight)
    public var fullName: String

    public init(fullName: String)
    {
        self.fullName = fullName
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
            let descriptor = FetchDescriptor<SavedTaggedPackage>(
                predicate: #Predicate { $0.fullName == fullName }
            )

            if let existingPackage = try modelContext.fetch(descriptor).first
            {
                modelContext.delete(existingPackage)
            }
        }
        catch
        {
            AppConstants.shared.logger.error("Failed to fetch package for deletion: \(error.localizedDescription)")
        }
    }
}
