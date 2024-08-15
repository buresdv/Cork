//
//  Service Detail.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import SwiftUI

enum ReasonsForServiceLoadingFailure
{
    case couldNotDecipherJSON
    case couldNotParseJSON
}

struct ServiceDetailView: View
{
    let service: HomebrewService

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
                        ServiceHeaderComplex(service: service)

                        BasicServiceInfoView(service: service, serviceDetails: serviceDetails)

                        ServiceLocationsView(service: service, serviceDetails: serviceDetails)
                    }

                    Spacer()

                    ServiceModificationButtons(service: service)
                }
            }
        }
        .task(priority: .userInitiated)
        {
            AppConstants.logger.log("Service details pane for service \(service.name) appeared; will try to load details")

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
                AppConstants.logger.error("Failed while loading services: \(servicesLoadingError.localizedDescription)")
                erroredOutWhileLoadingServiceDetails = true
            }
        }
        .onDisappear
        {
            AppConstants.logger.log("Service details pane for \(service.name) disappeared; will purge details tracker")

            serviceDetails = nil
        }
    }
}
