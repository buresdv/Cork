//
//  Adoption Results List.swift
//  Cork
//
//  Created by David Bureš - P on 08.10.2025.
//

import CorkModels
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
                    switch error
                    {
                    case .unimplemented(let rawTerminalOutput):
                        adoptionFailure_unimplementedError(
                            failedAdoptionCandidate: failedAdoptionCandidate,
                            rawTerminalOutput: rawTerminalOutput
                        )

                    case .implemented(let implementedError):
                        adoptionFailure_implementedError(
                            failedAdoptionCandidate: failedAdoptionCandidate,
                            error: implementedError
                        )
                    }
                }
            }
            .listStyle(.bordered(alternatesRowBackgrounds: true))
            .frame(minHeight: 100)
        }
    }

    // MARK: - View Builders

    @ViewBuilder
    func adoptionCandidateName(
        fromAdoptionCandidate failedAdoptionCandidate: BrewPackagesTracker.AdoptableApp,
    ) -> some View
    {
        if let adoptionCandidateCaskName = failedAdoptionCandidate.selectedAdoptionCandidateCaskName
        {
            Text(adoptionCandidateCaskName)
        }
        else
        {
            Text("mass-adoption.failed.details-dropdown.missing-candidate-cask-name")
        }
    }

    @ViewBuilder
    func adoptionFailure_implementedError(
        failedAdoptionCandidate: BrewPackagesTracker.AdoptableApp,
        error: MassAppAdoptionView.AdoptionAttemptFailure.AdoptionAttemptError.ImplementedError
    ) -> some View
    {
        VStack(alignment: .leading, spacing: 2)
        {
            adoptionCandidateName(fromAdoptionCandidate: failedAdoptionCandidate)
                .font(.body)

            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.multicolor)
        }
    }

    @ViewBuilder
    func adoptionFailure_unimplementedError(
        failedAdoptionCandidate: BrewPackagesTracker.AdoptableApp,
        rawTerminalOutput: String
    ) -> some View
    {
        HStack
        {
            adoptionCandidateName(fromAdoptionCandidate: failedAdoptionCandidate)

            Spacer()

            Button
            {
                openWindow(id: .errorInspectorWindowID, value: rawTerminalOutput)
            } label: {
                Label("action.inspect-error", systemImage: "info.circle")
            }
            .labelStyle(.iconOnly)
        }
    }
}
