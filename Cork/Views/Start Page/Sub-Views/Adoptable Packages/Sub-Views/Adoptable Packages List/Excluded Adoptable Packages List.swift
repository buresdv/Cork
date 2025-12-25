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
    
    var body: some View
    {
        AdoptablePackageListTemplate(
            adoptablePackageType: .ignoredPackages,
            searchText: $searchText
        ){
            ForEach(brewPackagesTracker.excludedAdoptableApps.prefix(numberOfMaxShownIgnoredAdoptableApps))
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
