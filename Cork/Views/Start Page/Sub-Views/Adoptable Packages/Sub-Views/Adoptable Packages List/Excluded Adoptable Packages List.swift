//
//  Excluded Adoptable Packages List.swift
//  Cork
//
//  Created by David Bureš - P on 25.12.2025.
//

import SwiftUI
import CorkModels
import CorkShared
import SwiftData

struct ExcludedAdoptablePackagesList: View
{
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker
    
    @State private var numberOfMaxShownIgnoredAdoptableApps: Int = 5
    
    @State private var searchText: String = ""
    
    @Query private var excludedApps: [ExcludedAdoptableApp]
    
    var displayedExcludedAdoptablePackages: ArraySlice<BrewPackagesTracker.AdoptableApp>
    {
        var filteredAdoptablePackages: [BrewPackagesTracker.AdoptableApp]
        {
            guard !searchText.isEmpty
            else
            {
                return brewPackagesTracker.excludedAdoptableApps
            }

            return brewPackagesTracker.excludedAdoptableApps.filter
            { adoptableApp in

                let appExecutableMatches: Bool = adoptableApp.appExecutable.localizedCaseInsensitiveContains(searchText)

                let adoptionCandidateMatches: Bool = adoptableApp.adoptionCandidates.contains
                { adoptionCandidate in
                    let caskNameMatches: Bool = adoptionCandidate.caskName.localizedCaseInsensitiveContains(searchText)

                    let caskDescriptionMatches: Bool = adoptionCandidate.caskDescription?.localizedCaseInsensitiveContains(searchText) ?? false

                    return caskNameMatches || caskDescriptionMatches
                }

                return appExecutableMatches || adoptionCandidateMatches
            }
        }

        return filteredAdoptablePackages.prefix(numberOfMaxShownIgnoredAdoptableApps)
    }
    
    var body: some View
    {
        AdoptablePackageListTemplate(
            adoptablePackageType: .ignoredPackages,
            searchText: $searchText
        ){
            ForEach(displayedExcludedAdoptablePackages)
            { ignoredApp in
                AdoptablePackageListItem(adoptableCask: ignoredApp, exclusionButtonType: .includeOnly)
                    .saturation(0.3)
            }
        } sectionHeaderContent: {
            EmptyView()
        } sectionFooterContent: {
            HStack(alignment: .center)
            {
                Button
                {
                    withAnimation
                    {
                        numberOfMaxShownIgnoredAdoptableApps += 10
                    }
                } label: {
                    Label("action.show-more", systemImage: "chevron.down")
                }
                .buttonStyle(.accessoryBar)
                .disabled(numberOfMaxShownIgnoredAdoptableApps >= brewPackagesTracker.excludedAdoptableApps.count)

                Spacer()

                Button
                {
                    withAnimation
                    {
                        numberOfMaxShownIgnoredAdoptableApps -= 10
                    }
                } label: {
                    Label("action.show-less", systemImage: "chevron.up")
                }
                .buttonStyle(.accessoryBar)
                .disabled(numberOfMaxShownIgnoredAdoptableApps < 7)
            }
        }

    }
}
