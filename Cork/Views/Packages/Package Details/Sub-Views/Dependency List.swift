//
//  Dependency List.swift
//  Cork
//
//  Created by David Bureš on 27.02.2023.
//

import SwiftUI

struct DependencyList: View
{
    @AppStorage("displayAdvancedDependencies") var displayAdvancedDependencies: Bool = false
    @AppStorage("showSearchFieldForDependenciesInPackageDetails") var showSearchFieldForDependenciesInPackageDetails: Bool = false
    
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
            return dependencies.filter({ $0.name.localizedCaseInsensitiveContains(dependencySearchText) })
        }
    }
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 5)
        {
            if showSearchFieldForDependenciesInPackageDetails
            {
                CustomSearchField(search: $dependencySearchText, customPromptText: "package-details.dependencies.search.prompt")
            }

            if displayAdvancedDependencies
            {
                Table(foundDependencies)
                {
                    TableColumn("package-details.dependencies.results.name")
                    { dependency in
                        Text(dependency.name)
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
                .frame(height: 100)
            }
            else
            {
                List(foundDependencies)
                { dependency in
                    Text(dependency.name)
                }
                .listStyle(.bordered(alternatesRowBackgrounds: true))
                .frame(height: 100)
            }
        }
    }
}
