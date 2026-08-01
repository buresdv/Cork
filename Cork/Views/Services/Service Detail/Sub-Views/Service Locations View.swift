//
//  Service Locations View.swift
//  Cork
//
//  Created by David Bureš on 21.03.2024.
//

import SwiftUI

struct ServiceLocationsView: View
{
    let service: HomebrewService

    var body: some View
    {
        Section
        {
            LabeledContent
            {
                Text(service.location.absoluteString)
            } label: {
                Text("service.location.label")
            }

            if let serviceDetails = service.details
            {
                LabeledContent
                {
                    Text(serviceDetails.rootDir?.absoluteString ?? String(localized: "services.status.none"))
                } label: {
                    Text("service.root-location.label")
                }

                LabeledContent
                {
                    Text(serviceDetails.logPath?.absoluteString ?? String(localized: "services.status.none"))
                } label: {
                    Text("service.log-location.label")
                }

                LabeledContent
                {
                    Text(serviceDetails.errorLogPath?.absoluteString ?? String(localized: "services.status.none"))
                } label: {
                    Text("service.error-log-location.label")
                }
            }
        }
    }
}
