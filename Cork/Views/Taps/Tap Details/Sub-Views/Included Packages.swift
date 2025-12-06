//
//  Included Packages.swift
//  Cork
//
//  Created by David Bureš on 28.09.2023.
//

import SwiftUI
import CorkModels

struct TapDetailsIncludedPackages: View
{
    let includedFormulae: [MinimalHomebrewPackage]
    let includedCasks: [MinimalHomebrewPackage]

    var body: some View
    {
        if !includedFormulae.isEmpty || !includedCasks.isEmpty
        {
            Section
            {
                if !includedFormulae.isEmpty
                {
                    DisclosureGroup("tap-details.included-formulae")
                    {
                        PackagesIncludedInTapList(packages: includedFormulae)
                    }
                    .disclosureGroupStyle(NoPadding())
                }

                if !includedCasks.isEmpty
                {
                    DisclosureGroup("tap-details.included-casks")
                    {
                        PackagesIncludedInTapList(packages: includedCasks)
                    }
                    .disclosureGroupStyle(NoPadding())
                }
            }
        }
    }
}
