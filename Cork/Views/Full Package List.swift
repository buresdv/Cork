//
//  Full Package List.swift
//  Cork
//
//  Created by David Bureš - P on 02.08.2026.
//

import SwiftUI
import CorkShared
import CorkModels

struct FullPackageList: View
{
    let packages: [MinimalHomebrewPackage]
    
    @State private var searchText: String = ""

    @State private var isShowingSearchField: Bool = false

    @FocusState var isSearchFieldFocused

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
                ForEach(packagesToDisplay)
                { minimalPackage in
                    HStack(alignment: .center)
                    {
                        if let initializedBrewPackageForDisplayInList: BrewPackage = .init(using: minimalPackage)
                        {
                            initializedBrewPackageForDisplayInList.nameView(withComponents: .boundVersion)

                            var isPackageAlreadyInstalled: Bool
                            {
                                return false
                            }

                            if isPackageAlreadyInstalled
                            {
                                PackageAlreadyInstalledPill()
                            }
                        }
                    }
                }
            } 
        }
        // .frame(height: 150)
        .listStyle(.bordered(alternatesRowBackgrounds: true))
        .scrollDisabled(false)
        .searchable(text: $searchText, placement: .toolbar, prompt: nil)
        .navigationTitle("package-list-inspector.title")
        .modify
        { viewProxy in
            if #available(macOS 15.0, *)
            {
                viewProxy
                    .searchFocused($isSearchFieldFocused)
            }
            else
            {
                viewProxy
            }
        }
        
    }
}
