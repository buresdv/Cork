//
//  Services Start Page.swift
//  Cork
//
//  Created by David Bureš on 17.10.2024.
//

import SwiftUI

struct ServicesStartPage: View
{
    @Environment(ServicesState.self) var servicesState: ServicesState
    @Environment(ServicesTracker.self) var servicesTracker: ServicesTracker

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
        if servicesState.isLoadingServices
        {
            ProgressView("service-status-page.loading")
        }
        else
        {
            if servicesTracker.services.isEmpty
            {
                if #available(macOS 14.0, *)
                {
                    ContentUnavailableView(label: {
                        Label("service-status-page.no-services-found", systemImage: "magnifyingglass")
                    }, description: {}, actions: {
                        LoadServicesButton()
                            .labelStyle(.titleOnly)
                    })
                }
                else
                {
                    Text("service-status-page.no-services-found")
                }
            }
            else
            {
                FullSizeGroupedForm
                {
                    Section
                    {
                        if !activeServices.isEmpty
                        {
                            GroupBoxHeadlineGroupWithArbitraryImage(image: Image("custom.square.stack.badge.play"), title: "service-status-page.active-services-\(activeServices.count)", mainText: "service-status-page.active-services.description", animateNumberChanges: true)
                        }

                        if !erroredOutServices.isEmpty
                        {
                            GroupBoxHeadlineGroupWithArbitraryImage(image: Image("custom.square.stack.trianglebadge.exclamationmark"), title: "service-status-page.errored-out-services-\(erroredOutServices.count)", mainText: "service-status-page.errored-out-services.description", animateNumberChanges: true)
                        }

                        if !inactiveServices.isEmpty
                        {
                            GroupBoxHeadlineGroupWithArbitraryImage(image: Image("custom.square.stack.badge.pause"), title: "service-status-page.inactive-services-\(inactiveServices.count)", mainText: "service-status-page.inactive-services.description", animateNumberChanges: true)
                        }

                        if !unknownServices.isEmpty
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
}
