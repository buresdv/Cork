//
//  Basic Service Info Section.swift
//  Cork
//
//  Created by David Bureš on 21.03.2024.
//

import SwiftUI

struct BasicServiceInfoView: View
{
    let service: HomebrewService

    var body: some View
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

            if let serviceDetails = service.details
            {
                LabeledContent
                {
                    Text(serviceDetails.loaded ? "generic.true" : "generic.false")
                } label: {
                    Text("service.loaded.label")
                }

                LabeledContent
                {
                    Text(serviceDetails.schedulable ? "generic.true" : "generic.false")
                } label: {
                    Text("service.schedulable.label")
                }
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
        }
    }
}
