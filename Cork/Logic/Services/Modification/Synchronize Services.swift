//
//  Synchronize Services.swift
//  Cork
//
//  Created by David Bureš on 12.05.2024.
//

import Foundation

extension ServicesTracker
{
    func synchronizeServices(preserveIDs: Bool) async throws(HomebrewServiceLoadingError)
    {
        let dummyServicesTracker: ServicesTracker = .init()

        try await dummyServicesTracker.loadServices()

        let updatedServices: Set<HomebrewService> = dummyServicesTracker.services

        if !preserveIDs
        {
            services = updatedServices
        }
        else
        {
            let originalServicesWithTheirUUIDs: [String: UUID] = services.reduce(into: [:])
            { result, originalService in
                result[originalService.name] = originalService.id
            }

            let updatedServicesWithOldIDs: Set<HomebrewService> = Set(updatedServices.map { updatedService in
                var copyUpdatedService: HomebrewService = updatedService

                if let preservedID = originalServicesWithTheirUUIDs[copyUpdatedService.name] {
                    copyUpdatedService.id = preservedID
                }

                return copyUpdatedService
            })

            services = updatedServicesWithOldIDs
        }
    }
}
