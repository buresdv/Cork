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
                CustomSearchField(search: $dependencySearchText, customPromptText: "Dependencies")
            }

            if displayAdvancedDependencies
            {
                Table(foundDependencies)
                {
                    TableColumn("Name")
                    { dependency in
                        Text(dependency.name)
                    }
                    TableColumn("Version")
                    { dependency in
                        Text(dependency.version)
                    }
                    TableColumn("Declaration Type")
                    { dependency in
                        if dependency.directlyDeclared
                        {
                            Text("Direct")
                        }
                        else
                        {
                            Text("Indirect")
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
