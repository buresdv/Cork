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
    @State private var includedFormulae: [String] = .init()
    @State private var includedCasks: [String] = .init()
    @State private var numberOfPackages: Int = 0

    @State private var erroredOut: Bool = false
    @State private var errorOutReason: String = ""

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
                    InlineFatalError(errorMessage: "alert.generic.couldnt-parse-json", errorDescription: errorOutReason)
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
                                        try await availableTaps.removeTap(
                                            name: tap.name,
                                            appState: appState)
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
            defer
            {
                isLoadingTapInfo = false
            }
            
            async let tapInfo = await shell(AppConstants.brewExecutablePath, ["tap-info", "--json", tap.name]).standardOutput

            do
            {
                guard let fullParsedTapInfo: TapInfo = try await parseTapInfo(from: tapInfo) else
                {
                    erroredOut = true
                    
                    return
                }

                homepage = fullParsedTapInfo.remote
                isOfficial = fullParsedTapInfo.official
                includedFormulae = fullParsedTapInfo.formulaNames
                includedCasks = fullParsedTapInfo.caskTokens

                numberOfPackages = includedFormulae.count + includedCasks.count
            }
            catch let parsingError
            {
                AppConstants.logger.error("Failed while parsing package info: \(parsingError, privacy: .public)")
                
                errorOutReason = parsingError.localizedDescription
                
                erroredOut = true
            }
        }
    }
}
