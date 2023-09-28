//
//  Basic Package Info.swift
//  Cork
//
//  Created by David Bureš on 26.09.2023.
//

import SwiftUI

struct BasicPackageInfoView: View
{
    let package: BrewPackage

    let tap: String
    let homepage: URL

    var body: some View
    {
        GroupBox
        {
            GridRow(alignment: .firstTextBaseline)
            {
                Text("Tap")
                Text(tap)
            }

            Divider()

            GridRow(alignment: .top)
            {
                Text("package-details.type")
                if package.isCask
                {
                    Text("package-details.type.cask")
                }
                else
                {
                    Text("package-details.type.formula")
                }
            }

            Divider()

            GridRow(alignment: .top)
            {
                Text("package-details.homepage")
                Link(destination: homepage)
                {
                    Text(homepage.absoluteString)
                }
            }
        }
    }
}
