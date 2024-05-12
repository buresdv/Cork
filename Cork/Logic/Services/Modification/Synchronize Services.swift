//
//  Synchronize Services.swift
//  Cork
//
//  Created by David Bureš on 12.05.2024.
//

import Foundation

extension ServicesTracker
{
    func synchronizeServices(preserveIDs: Bool) async throws
    {
        do
        {
            let dummyServicesState: ServicesState = .init()
            
            let updatedServices: Set<HomebrewService> = try await loadUpServices(servicesState: dummyServicesState)

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

                let updatedServicesWithOldIDs: Set<HomebrewService> = Set(updatedServices.map
                { updatedService in
                    
                    var copyUpdatedService = updatedService
                    
                    for originalServiceWithItsOldUUID in originalServicesWithTheirUUIDs
                    {
                        if originalServiceWithItsOldUUID.key == copyUpdatedService.name
                        {
                            copyUpdatedService.id = originalServiceWithItsOldUUID.value
                        }
                    }
                    
                    return copyUpdatedService
                })
                
                services = updatedServicesWithOldIDs
            }
        }
        catch let servicesLoadingError as HomebrewServiceLoadingError
        {
            /// Just rethrow the error further up the chain
            throw servicesLoadingError
        }
    }
}
