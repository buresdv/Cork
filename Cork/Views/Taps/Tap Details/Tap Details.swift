//
//  Tap Details.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import SwiftUI

class SelectedTapInfo: ObservableObject
{
    @Published var contents: String = .init()
}

struct TapDetailView: View
{
    @State var tap: BrewTap
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var availableTaps: AvailableTaps

    @StateObject var selectedTapInfo: SelectedTapInfo

    @State private var isLoadingTapInfo: Bool = true

    @State private var homepage: URL = .init(string: "https://google.com")!
    @State private var isOfficial: Bool = false
    @State private var includedFormulae: [String]?
    @State private var includedCasks: [String]?
    @State private var numberOfPackages: Int = 0

    @State private var isShowingIncludedFormulae: Bool = false
    @State private var isShowingIncludedCasks: Bool = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 15)
        {
            VStack(alignment: .leading, spacing: 5)
            {
                HStack(alignment: .center, spacing: 5)
                {
                    Text(tap.name)
                        .font(.title)

                    if isOfficial
                    {
                        Image(systemName: "checkmark.shield")
                            .help("tap-details.official-\(tap.name)")
                    }
                }
            }

            if isLoadingTapInfo
            {
                HStack(alignment: .center) {
                    VStack(alignment: .center) {
                        ProgressView {
                            Text("tap-details.loading")
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            else
            {
                VStack(alignment: .leading, spacing: 10)
                {
                    Text("tap-details.info")
                        .font(.title2)

                    GroupBox
                    {
                        Grid(alignment: .leading, horizontalSpacing: 20)
                        {
                            GridRow(alignment: .firstTextBaseline) {
                                Text("tap-details.contents")
                                
                                if includedFormulae == nil && includedCasks == nil
                                {
                                    Text("tap-details.contents.none")
                                }
                                else if includedFormulae != nil && includedCasks == nil
                                {
                                    Text("tap-details.contents.formulae-only")
                                }
                                else if includedCasks != nil && includedFormulae == nil
                                {
                                    Text("tap-details.contents.casks-only")
                                }
                                else if includedFormulae?.count ?? 0 > includedCasks?.count ?? 0
                                {
                                    Text("tap-details.contents.formulae-mostly")
                                }
                                else if includedFormulae?.count ?? 0 < includedCasks?.count ?? 0
                                {
                                    Text("tap-details.contents.casks-mostly")
                                }
                            }
                            
                            Divider()
                            
                            GridRow(alignment: .firstTextBaseline) {
                                Text("tap-details.package-count")
                                Text(String(numberOfPackages))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Divider()
                            
                            GridRow(alignment: .firstTextBaseline)
                            {
                                Text("tap-details.homepage")
                                Link(destination: homepage)
                                {
                                    Text(homepage.absoluteString)
                                }
                            }
                        }
                    }

                    if includedFormulae != nil || includedCasks != nil
                    {
                        GroupBox
                        {
                            VStack
                            {
                                if let includedFormulae
                                {
                                    DisclosureGroup("tap-details.included-formulae", isExpanded: $isShowingIncludedFormulae)
                                    {}
                                    .disclosureGroupStyle(NoPadding())
                                    if isShowingIncludedFormulae
                                    {
                                        PackagesIncludedInTapList(packages: includedFormulae)
                                    }
                                }

                                if includedFormulae != nil && includedCasks != nil
                                {
                                    Divider()
                                }
                                
                                if let includedCasks
                                {
                                    DisclosureGroup("tap-details.included-casks", isExpanded: $isShowingIncludedCasks)
                                    {}
                                    .disclosureGroupStyle(NoPadding())
                                    if isShowingIncludedCasks
                                    {
                                        PackagesIncludedInTapList(packages: includedCasks)
                                    }
                                }
                            }
                        }
                    }

                    Spacer()
                    
                    HStack
                    {
                        Spacer()
                        
                        UninstallationProgressWheel()
                        
                        Button {
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
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear
        {
            Task(priority: .userInitiated)
            {
                async let tapInfo = await shell(AppConstants.brewExecutablePath.absoluteString, ["tap-info", "--json", tap.name]).standardOutput

                let parsedJSON = try await parseJSON(from: tapInfo)

                homepage = getTapHomepageFromJSON(json: parsedJSON)
                isOfficial = getTapOfficialStatusFromJSON(json: parsedJSON)
                includedFormulae = getFormulaeAvailableFromTap(json: parsedJSON, tap: tap)
                includedCasks = getCasksAvailableFromTap(json: parsedJSON, tap: tap)

                numberOfPackages = Int(includedFormulae?.count ?? 0) + Int(includedCasks?.count ?? 0)
                
                isLoadingTapInfo = false
            }
        }
    }
}
