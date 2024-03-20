//
//  Service Detail.swift
//  Cork
//
//  Created by David Bureš on 20.03.2024.
//

import SwiftUI

struct ServiceDetailView: View
{
    let service: HomebrewService

    var body: some View
    {
        FullSizeGroupedForm
        {
            Section
            {
                if let serviceUser = service.user
                {
                    LabeledContent
                    {
                        Text(serviceUser)
                    } label: {
                        Text("service.user.label")
                    }
                }
                
                LabeledContent
                {
                    Text(service.status.displayableName)
                } label: {
                    Text("service.status.label")
                }

                if let serviceExitCode = service.exitCode
                {
                    LabeledContent
                    {
                        Text(String(serviceExitCode))
                    } label: {
                        Text("service.exit-code.label")
                    }
                }

            } header: {
                Text(service.name)
                    .font(.title)
            }
            
            Section
            {
                LabeledContent
                {
                    Text(service.location.absoluteString)
                } label: {
                    Text("service.location.label")
                }
            }
        }
    }
}
