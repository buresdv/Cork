//
//  Packages Included in Tap.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import CorkModels
import SwiftUI

struct PackagesIncludedInTapList: View
{
    @Environment(\.selectedTap) var selectedTap: BrewTap?

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    let packages: [MinimalHomebrewPackage]

    @State private var searchString: String = ""

    var packagesToDisplay: [MinimalHomebrewPackage]
    {
        if searchString.isEmpty
        {
            return packages.sorted
            {
                $0.name < $1.name
            }
        }
        else
        {
            return packages.filter { $0.name.localizedCaseInsensitiveContains(searchString) }.sorted
            {
                $0.name < $1.name
            }
        }
    }

    var body: some View
    {
        VStack(spacing: 5)
        {
            CustomSearchField(search: $searchString, customPromptText: "tap-details.included-packages.search.prompt")
            List
            {
                ForEach(packagesToDisplay)
                { (minimalPackage: MinimalHomebrewPackage) in
                    HStack(alignment: .center)
                    {
                        if let initializedBrewPackageForDisplayInList: BrewPackage = .init(using: minimalPackage)
                        {
                            SanitizedPackageName(
                                package: initializedBrewPackageForDisplayInList,
                                shouldShowVersion: true
                            )

                            var isPackageAlreadyInstalled: Bool
                            {
                                var packageContainedInFormulae: Bool {
                                    return brewPackagesTracker.successfullyLoadedFormulae.contains { installedPackage in
                                        installedPackage.getPackageName(withPrecision: .precise) == minimalPackage.name
                                    }
                                }
                                
                                var packageContainedInCasks: Bool {
                                    return brewPackagesTracker.successfullyLoadedCasks.contains { installedPackage in
                                        installedPackage.getPackageName(withPrecision: .precise) == minimalPackage.name
                                    }
                                }
                                  
                                return packageContainedInFormulae || packageContainedInCasks
                            }
                            
                            if isPackageAlreadyInstalled
                            {
                                PillTextWithLocalizableText(localizedText: "add-package.result.already-installed")
                            }
                        }
                    }
                    .contextMenu
                    {
                        contextMenu(packageToPreview: minimalPackage)
                    }
                }
            }
            .frame(height: 150)
            .listStyle(.bordered(alternatesRowBackgrounds: true))
        }
    }

    @ViewBuilder
    func contextMenu(packageToPreview: MinimalHomebrewPackage) -> some View
    {
        PreviewPackageButton(packageToPreview: packageToPreview)
    }
}
