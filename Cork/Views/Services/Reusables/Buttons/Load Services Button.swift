//
//  Load Services Button.swift
//  Cork
//
//  Created by David Bureš on 17.10.2024.
//

import SwiftUI
import ButtonKit

struct LoadServicesButton: View
{
    @Environment(\.controlActiveState) var controlActiveState: ControlActiveState

    @Environment(ServicesState.self) var servicesState: ServicesState
    @Environment(ServicesTracker.self) var servicesTracker: ServicesTracker

    var body: some View
    {
        AsyncButton
        {
            await loadServices()
        } label: {
            Label("action.reload-services", systemImage: "arrow.clockwise")
                .help("action.reload-services")
        }
        .asyncButtonStyle(.plainStyle)
    }

    // This function is duplicated in `HomebrewServicesView`
    private func loadServices() async
    {
        print("Control active state: \(controlActiveState)")

        if servicesState.isLoadingServices == false
        {
            servicesState.isLoadingServices = true
        }

        defer
        {
            servicesState.isLoadingServices = false
        }

        do
        {
            try await servicesTracker.loadServices()
        }
        catch let servicesLoadingError as HomebrewServiceLoadingError
        {
            switch servicesLoadingError
            {
            case .homebrewOutdated:
                servicesState.showError(.homebrewOutdated)
            default:
                servicesState.showError(.couldNotLoadServices(error: servicesLoadingError.localizedDescription))
            }
        }
        catch let servicesLoadingError
        {
            servicesState.showError(.couldNotLoadServices(error: servicesLoadingError.localizedDescription))
        }
    }
}
