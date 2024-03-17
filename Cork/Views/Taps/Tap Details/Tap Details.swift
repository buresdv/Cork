//
//  Tap Details.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import SwiftUI

struct TapDetailView: View, Sendable
{
    let tap: BrewTap

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var availableTaps: AvailableTaps

    @State private var isLoadingTapInfo: Bool = true

    @State private var homepage: URL?
    @State private var isOfficial: Bool = false
    @State private var includedFormulae: Set<String>?
    @State private var includedCasks: Set<String>?
    @State private var numberOfPackages: Int = 0

    @State private var erroredOut: Bool = false

    var body: some View
    {
        VStack(alignment: .leading)
        {
            if isLoadingTapInfo
            {
                HStack(alignment: .center)
                {
                    VStack(alignment: .center)
                    {
                        ProgressView
                        {
                            Text("tap-details.loading")
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            else
            {
                if erroredOut
                { /// Show this if there was an error during the info loading process
                    InlineFatalError(errorMessage: "alert.generic.couldnt-parse-json")
                }
                else
                {
                    VStack(alignment: .leading, spacing: 10)
                    {
                        FullSizeGroupedForm
                        {
                            TapDetailsInfo(
                                tap: tap,
                                isOfficial: isOfficial,
                                includedFormulae: includedFormulae,
                                includedCasks: includedCasks,
                                numberOfPackages: numberOfPackages,
                                homepage: homepage
                            )

                            TapDetailsIncludedPackages(includedFormulae: includedFormulae, includedCasks: includedCasks)
                        }
                        .scrollDisabled(true)

                        ButtonBottomRow
                        {
                            HStack
                            {
                                Spacer()

                                UninstallationProgressWheel()

                                Button
                                {
                                    Task(priority: .userInitiated)
                                    {
                                        try await removeTap(name: tap.name, availableTaps: availableTaps, appState: appState)
                                    }
                                } label: {
                                    Text("tap-details.remove-\(tap.name)")
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(minWidth: 450, minHeight: 400, alignment: .topLeading)
        .task(priority: .userInitiated)
        {
            async let tapInfo = await shell(AppConstants.brewExecutablePath, ["tap-info", "--json", tap.name]).standardOutput

            do
            {
                let parsedJSON = try await parseJSON(from: tapInfo)

                homepage = getTapHomepageFromJSON(json: parsedJSON)
                isOfficial = getTapOfficialStatusFromJSON(json: parsedJSON)
                includedFormulae = getFormulaeAvailableFromTap(json: parsedJSON, tap: tap)
                includedCasks = getCasksAvailableFromTap(json: parsedJSON, tap: tap)

                numberOfPackages = Int(includedFormulae?.count ?? 0) + Int(includedCasks?.count ?? 0)

                isLoadingTapInfo = false
            }
            catch let parsingError
            {
                AppConstants.logger.error("Failed while parsing package info: \(parsingError, privacy: .public)")
                erroredOut = true
            }
        }
    }
}
