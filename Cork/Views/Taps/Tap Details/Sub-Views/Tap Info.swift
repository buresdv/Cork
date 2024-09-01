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
    
    var tapInfo: TapInfo

    var roughPackageOverview: LocalizedStringResource
    {
        if tapInfo.formulaNames.isEmpty && tapInfo.caskTokens.isEmpty
        {
            return "tap-details.contents.none"
        }
        else if !tapInfo.formulaNames.isEmpty && tapInfo.caskTokens.isEmpty
        {
            return "tap-details.contents.formulae-only"
        }
        else if !tapInfo.caskTokens.isEmpty && tapInfo.formulaNames.isEmpty
        {
            return "tap-details.contents.casks-only"
        }
        else if tapInfo.formulaNames.count > tapInfo.caskTokens.count
        {
            return "tap-details.contents.formulae-mostly"
        }
        else if tapInfo.formulaNames.count < tapInfo.caskTokens.count
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
                Text(tapInfo.numberOfPackages.formatted())
            } label: {
                Text("tap-details.package-count")
            }

            if let homepage = tapInfo.remote
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
                TapDetailsTitle(tap: tap, isOfficial: tapInfo.official)

                Text("tap-details.info")
                    .font(.title2)
            }
        }
    }
}
