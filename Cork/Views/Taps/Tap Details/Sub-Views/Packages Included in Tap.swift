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

    @State var packages: [String]

    @State private var searchString: String = ""

    var body: some View
    {
        VStack(spacing: 5)
        {
            CustomSearchField(search: $searchString, customPromptText: "tap-details.included-packages.search.prompt")
            ScrollView
            {
                LazyVStack(spacing: 0)
                {
                    ForEach(Array(searchString.isEmpty ? packages.enumerated() : packages.filter { $0.contains(searchString) }.enumerated()), id: \.offset)
                    { index, package in
                        HStack(alignment: .center)
                        {
                            Text(package)

                            if brewData.installedFormulae.contains(where: { $0.name == package }) || brewData.installedCasks.contains(where: { $0.name == package })
                            {
                                PillTextWithLocalizableText(localizedText: "add-package.result.already-installed")
                            }
                        }
                        .padding(6)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .background(index % 2 == 0 ? Color(nsColor: NSColor.alternatingContentBackgroundColors[0]) : Color(nsColor: NSColor.alternatingContentBackgroundColors[1]))
                    }
                }
            }
            .frame(maxHeight: 150)
            .border(Color(nsColor: .lightGray))
        }
    }
}
