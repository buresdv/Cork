//
//  Homebrew Services View.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import SwiftUI

struct HomebrewServicesView: View
{
    @Environment(\.controlActiveState) var controlActiveState

    @StateObject var servicesTracker: ServicesTracker = .init()
    @StateObject var servicesState: ServicesState = .init()

    var activeServices: Set<HomebrewService>
    {
        return servicesTracker.services.filter { $0.status == .scheduled || $0.status == .started }
    }

    var unknownServices: Set<HomebrewService>
    {
        return servicesTracker.services.filter { $0.status == .unknown }
    }

    var erroredOutServices: Set<HomebrewService>
    {
        return servicesTracker.services.filter { $0.status == .error }
    }

    var inactiveServices: Set<HomebrewService>
    {
        return servicesTracker.services.subtracting(activeServices).subtracting(unknownServices).subtracting(erroredOutServices)
    }

    var body: some View
    {
        NavigationSplitView
        {
            ServicesSidebarView()
        } detail: {
            if servicesState.isLoadingServices
            {
                ProgressView("service-status-page.loading")
            }
            else
            {
                if servicesTracker.services.isEmpty
                {
                    Text("service-status-page.no-services-found")
                }
                else
                {
                    FullSizeGroupedForm
                    {
                        Section
                        {
                            if activeServices.count != 0
                            {
                                GroupBoxHeadlineGroupWithArbitraryImage(image: Image("custom.square.stack.badge.play"), title: "service-status-page.active-services-\(activeServices.count)", mainText: "service-status-page.active-services.description", animateNumberChanges: true)
                            }

                            if erroredOutServices.count != 0
                            {
                                GroupBoxHeadlineGroupWithArbitraryImage(image: Image("custom.square.stack.trianglebadge.exclamationmark"), title: "service-status-page.errored-out-services-\(erroredOutServices.count)", mainText: "service-status-page.errored-out-services.description", animateNumberChanges: true)
                            }

                            if inactiveServices.count != 0
                            {
                                GroupBoxHeadlineGroupWithArbitraryImage(image: Image("custom.square.stack.badge.pause"), title: "service-status-page.inactive-services-\(inactiveServices.count)", mainText: "service-status-page.inactive-services.description", animateNumberChanges: true)
                            }

                            if unknownServices.count != 0
                            {
                                GroupBoxHeadlineGroupWithArbitraryImage(image: Image("custom.square.stack.badge.questionmark"), title: "service-status-page.unknown-services-\(unknownServices.count)", mainText: "service-status-page.unknown-services.description", animateNumberChanges: true)
                            }
                        } header: {
                            Text("service-status-page.title")
                                .font(.title)
                        }
                    }
                }
            }
        }
        .environmentObject(servicesTracker)
        .environmentObject(servicesState)
        .navigationTitle("services.title")
        .navigationSubtitle(servicesState.isLoadingServices ? "service-status-page.loading" : "services.count.\(servicesTracker.services.count)")
        .task(priority: .userInitiated)
        {
            print("Control active state: \(controlActiveState)")
            do
            {
                servicesTracker.services = try await loadUpServices(servicesState: servicesState)
            }
            catch let servicesLoadingError
            {
                servicesState.showError(.couldNotLoadServices(error: servicesLoadingError.localizedDescription))
            }
        }
        .alert(isPresented: $servicesState.isShowingError, error: servicesState.errorToShow)
        { error in
            
        } message: { error in
            Text(error.failureReason)
        }
    }
}
