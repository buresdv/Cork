//
//  Tap Details Info.swift
//  Cork
//
//  Created by David Bureš on 28.09.2023.
//

import SwiftUI

struct TapDetailsInfo: View
{
    let includedFormulae: [String]?
    let includedCasks: [String]?

    let numberOfPackages: Int
    let homepage: URL

    var body: some View
    {
        Section
        {
            LabeledContent
            {
                if includedFormulae == nil && includedCasks == nil
                {
                    Text("tap-details.contents.none")
                }
                else if includedFormulae != nil && includedCasks == nil
                {
                    Text("tap-details.contents.formulae-only")
                }
                else if includedCasks != nil && includedFormulae == nil
                {
                    Text("tap-details.contents.casks-only")
                }
                else if includedFormulae?.count ?? 0 > includedCasks?.count ?? 0
                {
                    Text("tap-details.contents.formulae-mostly")
                }
                else if includedFormulae?.count ?? 0 < includedCasks?.count ?? 0
                {
                    Text("tap-details.contents.casks-mostly")
                }
            } label: {
                Text("tap-details.contents")
            }

            LabeledContent
            {
                Text(numberOfPackages.formatted())
            } label: {
                Text("tap-details.package-count")
            }

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
    }
}
