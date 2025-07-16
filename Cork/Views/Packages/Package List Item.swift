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
    
    var badgeView: Text? {
        
        var badgeComponents: [String] = .init()
        
        // MARK: - Add the various components to the badge
        
        if isPackageOutdated {
            badgeComponents.append("􀐫")
        }
        
        if packageItem.isPinned {
            badgeComponents.prepend("􀎧")
        }
        
        // MARK: - Assemble the final view
        
        guard !badgeComponents.isEmpty else
        {
            return nil
        }
        
        return Text(badgeComponents.joined(separator: " | "))
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

                    SanitizedPackageName(package: packageItem, shouldShowVersion: false)
                }
                
                Text(packageItem.getFormattedVersions())
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
            .badge(badgeView)
            .animation(.easeInOut, value: badgeView)
            #if hasAttribute(bouncy)
            .animation(.bouncy, value: packageItem.isTagged)
            #else
            .animation(.interpolatingSpring(stiffness: 80, damping: 10), value: packageItem.isTagged)
            #endif
        }
    }
}
