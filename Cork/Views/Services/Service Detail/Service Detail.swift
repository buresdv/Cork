//
//  Service Detail.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import SwiftUI
import CorkShared

enum ReasonsForServiceLoadingFailure
{
    case couldNotDecipherJSON
    case couldNotParseJSON
}

struct ServiceDetailView: View, DismissablePane
{
    @Environment(ServicesTracker.self) var servicesTracker: ServicesTracker
    
    let service: HomebrewService
    
    private var dynamicService: HomebrewService?
    {
        return servicesTracker.services.first(where: { $0.id == service.id })

    }

    private var serviceObjectToUse: HomebrewService
    {
        if dynamicService != nil
        {
            return dynamicService!
        }
        else
        {
            return service
        }
    }

    @State private var serviceDetails: ServiceDetails?

    @State private var isLoadingDetails: Bool = true

    @State private var erroredOutWhileLoadingServiceDetails: Bool = false

    // TODO: Implement this
    @State private var reasonForServiceLoadingFailure: ReasonsForServiceLoadingFailure = .couldNotDecipherJSON

    var body: some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            if isLoadingDetails
            {
                ProgressView
                {
                    Text("service-details.contents.loading")
                }
            }
            else
            {
                if erroredOutWhileLoadingServiceDetails
                {
                    InlineFatalError(errorMessage: "alert.generic.couldnt-parse-json")
                }
                else
                {
                    FullSizeGroupedForm
                    {
                        ServiceHeaderComplex(service: serviceObjectToUse)

                        BasicServiceInfoView(
                            service: serviceObjectToUse,
                            serviceDetails: serviceDetails
                        )

                        ServiceLocationsView(
                            service: serviceObjectToUse,
                            serviceDetails: serviceDetails
                        )
                    }

                    Spacer()

                    ServiceModificationButtons(service: service)
                }
            }
        }
        .task(id: service.id)
        {
            AppConstants.shared.logger.log("Service details pane for service \(service.name) appeared; will try to load details")

            defer
            {
                isLoadingDetails = false
            }

            do
            {
                serviceDetails = try await service.loadDetails()
            }
            catch let servicesLoadingError
            {
                AppConstants.shared.logger.error("Failed while loading services: \(servicesLoadingError.localizedDescription)")
                erroredOutWhileLoadingServiceDetails = true
            }
        }
        .onDisappear
        {
            AppConstants.shared.logger.log("Service details pane for \(service.name) disappeared; will purge details tracker")

            serviceDetails = nil
        }
    }
}
