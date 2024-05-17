//
//  Packages Included in Tap.swift
//  Cork
//
//  Created by David Bureš on 12.03.2023.
//

import SwiftUI

struct PackagesIncludedInTapList: View
{
    @EnvironmentObject var brewData: BrewDataStorage

    @State var packages: Set<String>

    @State private var searchString: String = ""

    var body: some View
    {
        VStack(spacing: 5)
        {
            CustomSearchField(search: $searchString, customPromptText: "tap-details.included-packages.search.prompt")
            ScrollView
            {
                List
                {
                    ForEach(Array(searchString.isEmpty ? packages.sorted() : packages.filter({ $0.localizedCaseInsensitiveContains(searchString) }).sorted()), id: \.self)
                    { package in
                        HStack(alignment: .center)
                        {
                            SanitizedPackageName(packageName: package, shouldShowVersion: true)

                            if brewData.installedFormulae.contains(where: { $0.name == package }) || brewData.installedCasks.contains(where: { $0.name == package })
                            {
                                PillTextWithLocalizableText(localizedText: "add-package.result.already-installed")
                            }
                        }
                    }
                }
                .frame(height: 150)
                .listStyle(.bordered(alternatesRowBackgrounds: true))
            }
        }
    }
}
