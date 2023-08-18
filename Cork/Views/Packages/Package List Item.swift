//
//  Package List Item.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

struct PackageListItem: View
{
    var packageItem: BrewPackage

    var body: some View
    {
        HStack
        {
            HStack(alignment: .firstTextBaseline)
            {
                HStack(alignment: .firstTextBaseline, spacing: 5)
                {
                    if packageItem.isTagged
                    {
                        Circle()
                            .frame(width: 10, height: 10, alignment: .center)
                            .foregroundStyle(.blue)
                            .transition(.scale)
                    }

                    Text(packageItem.name)
                }
                
                Text(returnFormattedVersions(packageItem.versions))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .animation(.bouncy, value: packageItem.isTagged)
            .transition(.slide)
        }
    }
}
