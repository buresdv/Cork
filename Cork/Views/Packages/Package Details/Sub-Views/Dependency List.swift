//
//  Dependency List.swift
//  Cork
//
//  Created by David Bureš on 27.02.2023.
//

import CorkModels
import Defaults
import FactoryKit
import SwiftUI

struct DependencyList: View
{
    @Default(.displayAdvancedDependencies) var displayAdvancedDependencies: Bool
    @Default(.showSearchFieldForDependenciesInPackageDetails) var showSearchFieldForDependenciesInPackageDetails: Bool

    @InjectedObservable(\.navigationManager) var navigationManager

    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    @State private var dependencySearchText: String = ""

    @State var dependencies: [BrewPackageDependency]

    var foundDependencies: [BrewPackageDependency]
    {
        if dependencySearchText.isEmpty
        {
            return dependencies
        }
        else
        {
            return dependencies.filter { $0.package.name(withPrecision: .precise).localizedCaseInsensitiveContains(dependencySearchText) }
        }
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 5)
        {
            if showSearchFieldForDependenciesInPackageDetails
            {
                CustomSearchField(search: $dependencySearchText, customPromptText: nil)
            }

            if displayAdvancedDependencies
            {
                Table(foundDependencies)
                {
                    TableColumn("package-details.dependencies.results.name")
                    { dependency in
                        dependency.package.nameView(
                            withComponents: .boundVersion,
                            isExemptFromHighlighting: false
                        )
                    }
                    TableColumn("package-details.dependencies.results.version")
                    { dependency in
                        Text(dependency.version)
                    }
                    TableColumn("package-details.dependencies.results.declaration")
                    { dependency in
                        if dependency.directlyDeclared
                        {
                            Text("package-details.dependencies.results.declaration.direct")
                        }
                        else
                        {
                            Text("package-details.dependencies.results.declaration.indirect")
                        }
                    }
                }
                .tableStyle(.bordered)
            }
            else
            {
                List(foundDependencies)
                { dependency in
                    dependency.package.nameView(
                        withComponents: .boundVersion,
                        isExemptFromHighlighting: false
                    )
                }
                .listStyle(.bordered(alternatesRowBackgrounds: true))
            }
        }
    }
}
