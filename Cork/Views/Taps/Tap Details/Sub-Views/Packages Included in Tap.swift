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
    @Environment(\.openWindow) var openWindow: OpenWindowAction
    
    @Environment(\.selectedTap) var selectedTap: BrewTap?

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    let packages: [MinimalHomebrewPackage]

    @State private var searchText: String = ""

    @State private var isShowingSearchField: Bool = false

    @State private var isSearchFieldFocused: Bool = false

    var packagesToDisplay: [MinimalHomebrewPackage]
    {
        if searchText.isEmpty
        {
            return packages.sorted
            {
                $0.internalName < $1.internalName
            }
        }
        else
        {
            return packages.filter { $0.name(withPrecision: .precise).localizedCaseInsensitiveContains(searchText) }.sorted
            {
                $0.internalName < $1.internalName
            }
        }
    }

    var body: some View
    {
        List
        {
            Section
            {
                ForEach(packagesToDisplay.prefix(7))
                { minimalPackage in
                    HStack(alignment: .center)
                    {
                        if let initializedBrewPackageForDisplayInList: BrewPackage = .init(using: minimalPackage)
                        {
                            initializedBrewPackageForDisplayInList.nameView(withComponents: .boundVersion)

                            var isPackageAlreadyInstalled: Bool
                            {
                                var packageContainedInFormulae: Bool
                                {
                                    return brewPackagesTracker.successfullyLoadedFormulae.contains
                                    { installedPackage in
                                        installedPackage.internalName == minimalPackage.internalName
                                    }
                                }

                                var packageContainedInCasks: Bool
                                {
                                    return brewPackagesTracker.successfullyLoadedCasks.contains
                                    { installedPackage in
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
            } header: {
                CustomSearchField(search: $searchText, isFocused: $isSearchFieldFocused, customPromptText: nil)
            } footer: {
                if packages.count > 7
                {
                    Button
                    {
                        openWindow(value: packages)
                    } label: {
                        Label("action.show-more", systemImage: "list.bullet.badge.ellipsis")
                    }
                    .buttonStyle(.accessoryBar)
                }
            }
        }
        // .frame(height: 150)
        .listStyle(.bordered(alternatesRowBackgrounds: true))
        .scrollDisabled(false)
    }

    @ViewBuilder
    func contextMenu(packageToPreview: MinimalHomebrewPackage) -> some View
    {
        PreviewPackageButton(packageToPreview: packageToPreview)
    }
}
