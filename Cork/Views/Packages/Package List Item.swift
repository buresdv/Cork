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
    
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker
    
    var isPackageOutdated: Bool
    {
        if outdatedPackageTracker.displayableOutdatedPackages.contains(where: { $0.package.name == packageItem.name })
        {
            return true
        }
        else
        {
            return false
        }
    }

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
                
                HStack(alignment: .center, spacing: 4)
                {
                    Text(packageItem.getFormattedVersions())
                    
                    if isPackageOutdated
                    {
                        Text("􀐫")
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .layoutPriority(-Double(2))
                .animation(.easeInOut, value: isPackageOutdated)
                
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
    }
}
