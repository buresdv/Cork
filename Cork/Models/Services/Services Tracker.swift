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

    /// Replace a service in the tracker.
    /// Use `performInPlaceReplacement` to preserve the UUID of the original service so the UI doesn't completely reset
    func replaceServiceInTracker(_ serviceToChange: HomebrewService, with newService: HomebrewService, performInPlaceReplacement: Bool)
    {
        services = Set(services.map
        { service in
            var copyService = service

            if copyService.name == serviceToChange.name
            {
                copyService = .init(
                    id: performInPlaceReplacement ? copyService.id : newService.id,
                    name: newService.name,
                    status: newService.status,
                    user: newService.user,
                    location: newService.location,
                    exitCode: newService.exitCode
                )
            }

            return copyService
        })
    }

    func changeServiceStatus(_ serviceToChange: HomebrewService, newStatus: ServiceStatus)
    {
        self.replaceServiceInTracker(
            serviceToChange,
            with: .init(
                name: serviceToChange.name,
                status: newStatus,
                user: serviceToChange.user,
                location: serviceToChange.location,
                exitCode: serviceToChange.exitCode),
            performInPlaceReplacement: true)
    }
}
