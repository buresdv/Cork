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

    @State var dependencies: [BrewPackageDependency]

    var body: some View
    {
        if displayAdvancedDependencies
        {
            Table(dependencies)
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
            List(dependencies)
            { dependency in
                Text(dependency.name)
            }
            .listStyle(.bordered(alternatesRowBackgrounds: true))
            .frame(height: 100)
        }
    }
}
