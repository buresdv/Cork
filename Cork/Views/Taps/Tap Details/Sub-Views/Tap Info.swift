//
//  Tap Details Info.swift
//  Cork
//
//  Created by David Bureš on 28.09.2023.
//

import SwiftUI

struct TapDetailsInfo: View
{
    let tap: BrewTap
    let isOfficial: Bool

    let includedFormulae: [String]
    let includedCasks: [String]

    let numberOfPackages: Int
    let homepage: URL?

    var roughPackageOverview: LocalizedStringResource
    {
        if includedFormulae.isEmpty && includedCasks.isEmpty
        {
            return "tap-details.contents.none"
        }
        else if !includedFormulae.isEmpty && includedCasks.isEmpty
        {
            return "tap-details.contents.formulae-only"
        }
        else if !includedCasks.isEmpty && includedFormulae.isEmpty
        {
            return "tap-details.contents.casks-only"
        }
        else if includedFormulae.count > includedCasks.count
        {
            return "tap-details.contents.formulae-mostly"
        }
        else if includedFormulae.count < includedCasks.count
        {
            return "tap-details.contents.casks-mostly"
        }
        else
        {
            return "tap-details.contents.none"
        }
    }

    var body: some View
    {
        Section
        {
            LabeledContent
            {
                Text(roughPackageOverview)
            } label: {
                Text("tap-details.contents")
            }

            LabeledContent
            {
                Text(numberOfPackages.formatted())
            } label: {
                Text("tap-details.package-count")
            }

            if let homepage
            {
                LabeledContent
                {
                    Link(destination: homepage)
                    {
                        Text(homepage.absoluteString)
                    }
                } label: {
                    Text("tap-details.homepage")
                }
            }
        } header: {
            VStack(alignment: .leading, spacing: 15)
            {
                TapDetailsTitle(tap: tap, isOfficial: isOfficial)

                Text("tap-details.info")
                    .font(.title2)
            }
        }
    }
}
