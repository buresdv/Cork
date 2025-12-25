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
    
    @State private var searchText: String = ""
    
    @Query private var excludedApps: [ExcludedAdoptableApp]
    
    var displayedAdoptablePackages: ArraySlice<BrewPackagesTracker.AdoptableApp>
    {
        var filteredAdoptablePackages: [BrewPackagesTracker.AdoptableApp]
        {
            guard !searchText.isEmpty else
            {
                return brewPackagesTracker.adoptableAppsNonExcluded
            }
            return brewPackagesTracker.adoptableAppsNonExcluded.filter
            { adoptableApp in
                return adoptableApp.appExecutable.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filteredAdoptablePackages.prefix(numberOfMaxShownAdoptableApps)
    }
    
    var body: some View
    {
        AdoptablePackageListTemplate(adoptablePackageType: .adoptablePackages, searchText: $searchText) {
            ForEach(displayedAdoptablePackages)
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
        } sectionHeaderContent: {
            HStack(alignment: .center, spacing: 10)
            {
                deselectAllButton

                selectAllButton
            }
        } sectionFooterContent: {
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
        .animation(.smooth, value: displayedAdoptablePackages)
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
