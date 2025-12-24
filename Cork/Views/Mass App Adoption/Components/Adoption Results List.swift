//
//  Adoption Results List.swift
//  Cork
//
//  Created by David Bureš - P on 08.10.2025.
//

import SwiftUI

struct AdoptionResultsList: View
{
    @Environment(\.openWindow) var openWindow: OpenWindowAction
    
    @Environment(MassAppAdoptionView.MassAppAdoptionTacker.self) var massAppAdoptionTracker: MassAppAdoptionView.MassAppAdoptionTacker
    
    var body: some View
    {
        DisclosureGroup("mass-adoption.failed.details-dropdown.label")
        {
            List(massAppAdoptionTracker.unsuccessfullyAdoptedApps)
            { unsuccessfullyAdoptedApp in
                if case .failedWithError(let failedAdoptionCandidate, let error) = unsuccessfullyAdoptedApp
                {
                    HStack(alignment: .center)
                    {
                        if let adoptionCandidateCaskName = failedAdoptionCandidate.selectedAdoptionCandidateCaskName
                        {
                            Text(adoptionCandidateCaskName)
                        }
                        else
                        {
                            Text("mass-adoption.failed.details-dropdown.missing-candidate-cask-name")
                        }
                        
                        Spacer()
                        
                        Button {
                            openWindow(id: .errorInspectorWindowID, value: error)
                        } label: {
                            Label("action.inspect-error", systemImage: "info.circle")
                        }
                        .labelStyle(.iconOnly)

                    }
                }
            }
            .listStyle(.bordered(alternatesRowBackgrounds: true))
            .frame(minHeight: 100)
        }
    }
}
