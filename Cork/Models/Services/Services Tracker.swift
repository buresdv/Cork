//
//  Services Tracker.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import Foundation

@MainActor
class ServicesTracker: ObservableObject
{
    @Published var services: Set<HomebrewService> = .init()

    func changeServiceStatus(_ serviceToChange: HomebrewService, newStatus: ServiceStatus)
    {       
        self.services = Set(self.services.map({ service in
            var copyService = service
            
            if copyService.name == serviceToChange.name
            {
                copyService.status = newStatus
            }
            
            return copyService
        }))
    }
}
