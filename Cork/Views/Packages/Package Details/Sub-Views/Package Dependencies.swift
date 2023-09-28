//
//  Package Dependencies.swift
//  Cork
//
//  Created by David Bureš on 28.09.2023.
//

import SwiftUI

struct PackageDependencies: View {

    let dependencies: [BrewPackageDependency]?

    var body: some View {
        if let dependencies
        {
            Section
            {
                VStack
                {
                    DisclosureGroup("package-details.dependencies")
                    {
                        DependencyList(dependencies: dependencies)
                    }
                    .disclosureGroupStyle(NoPadding())
                }
            }
        }
    }
}
