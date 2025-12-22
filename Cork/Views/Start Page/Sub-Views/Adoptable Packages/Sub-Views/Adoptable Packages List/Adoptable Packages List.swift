//
//  Adoptable Packages List.swift
//  Cork
//
//  Created by David Bureš - P on 22.12.2025.
//

import SwiftUI
import CorkModels
import CorkShared
import SwiftData

struct AdoptablePackagesList: View
{
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    
    @State private var numberOfMaxShownAdoptableApps: Int = 5
    
    @Query private var excludedApps: [ExcludedAdoptableApp]
    
    var body: some View
    {
        List
        {
            Section
            {
                ForEach(brewPackagesTracker.adoptableAppsNonExcluded.prefix(numberOfMaxShownAdoptableApps))
                { adoptableCask in
                    HStack(alignment: .center)
                    {
                        Toggle(isOn: Binding<Bool>(
                            get: {
                                adoptableCask.isMarkedForAdoption
                            }, set: { _ in
                                if let index = brewPackagesTracker.adoptableApps.firstIndex(where: { $0.id == adoptableCask.id })
                                {
                                    brewPackagesTracker.adoptableApps[index].changeMarkedState()
                                }
                            }
                        ))
                        {
                            EmptyView()
                        }
                        .labelsHidden()

                        AdoptablePackageListItem(adoptableCask: adoptableCask, exclusionButtonType: .excludeOnly)
                        /* .onTapGesture
                         {
                             if let index = brewPackagesTracker.adoptableApps.firstIndex(where: { $0.id == adoptableCask.id })
                             {
                                 brewPackagesTracker.adoptableApps[index].changeMarkedState()
                             }
                         } */
                    }
                }
            } header: {
                HStack(alignment: .center, spacing: 10)
                {
                    deselectAllButton

                    selectAllButton
                }
            } footer: {
                HStack(alignment: .center)
                {
                    Button
                    {
                        withAnimation
                        {
                            numberOfMaxShownAdoptableApps += 10
                        }
                    } label: {
                        Label("action.show-more", systemImage: "chevron.down")
                    }
                    .buttonStyle(.accessoryBar)
                    .disabled(numberOfMaxShownAdoptableApps >= brewPackagesTracker.adoptableAppsNonExcluded.count)

                    Spacer()

                    Button
                    {
                        withAnimation
                        {
                            numberOfMaxShownAdoptableApps -= 10
                        }
                    } label: {
                        Label("action.show-less", systemImage: "chevron.up")
                    }
                    .buttonStyle(.accessoryBar)
                    .disabled(numberOfMaxShownAdoptableApps < 7)
                }
            }
        }
        .listStyle(.bordered(alternatesRowBackgrounds: true))
        .animation(.smooth, value: excludedApps)
        .transition(.push(from: .top))
    }
    
    @ViewBuilder
    var deselectAllButton: some View
    {
        Button
        {
            AppConstants.shared.logger.debug("Will deselect all adoptable casks")

            for (index, _) in brewPackagesTracker.adoptableApps.enumerated()
            {
                brewPackagesTracker.adoptableApps[index].isMarkedForAdoption = false
            }

        } label: {
            Text("start-page.updated.action.deselect-all")
        }
        .buttonStyle(.accessoryBar)
        .disabled(brewPackagesTracker.adoptableAppsSelectedToBeAdopted.isEmpty)
    }

    @ViewBuilder
    var selectAllButton: some View
    {
        Button
        {
            AppConstants.shared.logger.debug("Will select all adoptable casks")

            for (index, _) in brewPackagesTracker.adoptableApps.enumerated()
            {
                brewPackagesTracker.adoptableApps[index].isMarkedForAdoption = true
            }

        } label: {
            Text("start-page.updated.action.select-all")
        }
        .buttonStyle(.accessoryBar)
        .disabled(!brewPackagesTracker.hasSelectedOnlySomeAppsToAdopt && brewPackagesTracker.adoptableAppsSelectedToBeAdopted == brewPackagesTracker.adoptableAppsNonExcluded)
    }
}
