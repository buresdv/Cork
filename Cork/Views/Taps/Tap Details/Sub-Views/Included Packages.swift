//
//  Included Packages.swift
//  Cork
//
//  Created by David Bureš on 28.09.2023.
//

import SwiftUI

struct TapDetailsIncludedPackages: View
{
    let includedFormulae: [String]?
    let includedCasks: [String]?

    var body: some View
    {
        if includedFormulae != nil || includedCasks != nil
        {
            Section
            {
                if let includedFormulae
                {
                    DisclosureGroup("tap-details.included-formulae")
                    {
                        PackagesIncludedInTapList(packages: includedFormulae)
                    }
                    .disclosureGroupStyle(NoPadding())
                }

                if let includedCasks
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
