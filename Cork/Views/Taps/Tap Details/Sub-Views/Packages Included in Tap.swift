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
                $0.internalName < $1.internalName
            }
        }
        else
        {
            return packages.filter { $0.name(withPrecision: .precise).localizedCaseInsensitiveContains(searchString) }.sorted
            {
                $0.internalName < $1.internalName
            }
        }
    }

    var body: some View
    {
        VStack(spacing: 5)
        {
            CustomSearchField(search: $searchString, customPromptText: "tap-details.included-packages.search.prompt")
            List(packagesToDisplay)
            { minimalPackage in
                HStack(alignment: .center)
                {
                    if let initializedBrewPackageForDisplayInList: BrewPackage = .init(using: minimalPackage)
                    {
                        initializedBrewPackageForDisplayInList.nameView(withComponents: .boundVersion)

                        var isPackageAlreadyInstalled: Bool
                        {
                            var packageContainedInFormulae: Bool {
                                return brewPackagesTracker.successfullyLoadedFormulae.contains { installedPackage in
                                    installedPackage.internalName == minimalPackage.internalName
                                }
                            }
                            
                            var packageContainedInCasks: Bool {
                                return brewPackagesTracker.successfullyLoadedCasks.contains { installedPackage in
                                    installedPackage.internalName == minimalPackage.internalName
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
