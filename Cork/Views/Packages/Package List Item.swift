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

                    SanitizedPackageName(packageName: packageItem.name, shouldShowVersion: false)
                }
                
                Text(returnFormattedVersions(packageItem.versions))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .layoutPriority(-Double(2))
                
                if packageItem.isBeingModified
                {
                    Spacer()
                    
                    ProgressView()
                        .frame(height: 5)
                        .scaleEffect(0.5)
                }
            }
            #if hasAttribute(bouncy)
                .animation(.bouncy, value: packageItem.isTagged)
            #else
                .animation(.interpolatingSpring(stiffness: 80, damping: 10), value: packageItem.isTagged)
            #endif
        }
        .dropDestination(for: HomebrewBackup.self) { items, location in
            print(items)
            print(location)
            
            return true
        } isTargeted: { isTargeted in
            ProgressView()
        }

    }
}
