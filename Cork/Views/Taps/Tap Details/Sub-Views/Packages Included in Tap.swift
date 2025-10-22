//
//  Packages Included in Tap.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import SwiftUI

struct PackagesIncludedInTapList: View
{
    @Environment(\.selectedTap) var selectedTap: BrewTap?
    
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker

    let packages: [MinimalHomebrewPackage]

    @State private var searchString: String = ""

    var packagesToDisplay: [MinimalHomebrewPackage]
    {
        if searchString.isEmpty
        {
            return packages.sorted {
                return $0.name < $1.name
            }
        }
        else
        {
            return packages.filter({ $0.name.localizedCaseInsensitiveContains(searchString) }).sorted {
                $0.name < $1.name
            }
        }
    }
    
    var body: some View
    {
        VStack(spacing: 5)
        {
            CustomSearchField(search: $searchString, customPromptText: "tap-details.included-packages.search.prompt")
            ScrollView
            {
                List
                {
                    ForEach(packagesToDisplay)
                    { package in
                        HStack(alignment: .center)
                        {
                            SanitizedPackageName(package: .init(name: package.name, type: .formula, installedOn: nil, versions: [], url: nil, sizeInBytes: nil, downloadCount: nil), shouldShowVersion: true)

                            if brewPackagesTracker.successfullyLoadedFormulae.contains(where: { $0.name == package.name }) || brewPackagesTracker.successfullyLoadedCasks.contains(where: { $0.name == package.name })
                            {
                                PillTextWithLocalizableText(localizedText: "add-package.result.already-installed")
                            }
                        }
                        .contextMenu
                        {
                            contextMenu(packageToPreview: package)
                        }
                    }
                }
                .frame(height: 150)
                .listStyle(.bordered(alternatesRowBackgrounds: true))
            }
        }
    }
    
    @ViewBuilder
    func contextMenu(packageToPreview: MinimalHomebrewPackage) -> some View
    {
        PreviewPackageButton(packageToPreview: packageToPreview)
    }
}
