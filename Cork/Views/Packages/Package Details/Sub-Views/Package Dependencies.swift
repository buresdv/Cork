//
//  Package Dependencies.swift
//  Cork
//
//  Created by David Bureš on 28.09.2023.
//

import SwiftUI

struct PackageDependencies: View
{
    let dependencies: [BrewPackageDependency]?

    @Binding var isDependencyDisclosureGroupExpanded: Bool

    var body: some View
    {
        if let dependencies
        {
            VStack
            {
                DisclosureGroup("package-details.dependencies", isExpanded: $isDependencyDisclosureGroupExpanded)
                {
                    DependencyList(dependencies: dependencies)
                }
            }
        }
    }
}
