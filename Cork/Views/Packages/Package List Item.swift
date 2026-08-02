//
//  Package List Item.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI
import CorkModels
import FactoryKit

struct PackageListItem: View
{
    var packageItem: BrewPackage

    @InjectedObservable(\.outdatedPackagesTracker) var outdatedPackagesTracker: OutdatedPackagesTracker

    var isPackageOutdated: Bool
    {
        if outdatedPackagesTracker.allDisplayableOutdatedPackages.contains(where: { $0.package.getCompletePackageName() == packageItem.getCompletePackageName() })
        {
            return true
        }
        else
        {
            return false
        }
    }

    var badgeView: Text?
    {
        var components: [Text] = []

        if packageItem.isPinned
        {
            components.append(Text(Image(systemName: "pin.fill")))
        }

        if isPackageOutdated
        {
            components.append(Text(Image(systemName: "clock")))
        }

        // MARK: Assemble the final view
        
        guard !components.isEmpty else { return nil }

        return components.dropFirst().reduce(into: components[0]) { result, text in
            result = result + Text(" | ") + text
        }
    }

    var body: some View
    {
        HStack
        {
            HStack(alignment: .firstTextBaseline)
            {
                if packageItem.isTagged
                {
                    Circle()
                        .frame(width: 10, height: 10, alignment: .center)
                        .foregroundStyle(.blue)
                        .transition(.scale)
                }

                packageItem.nameView(withComponents: .boundVersion, .installedVersions(packageItem.versions))
                {
                    SidebarContextMenu(package: packageItem)
                }

                if packageItem.isBeingModified
                {
                    Spacer()

                    ProgressView()
                        .frame(height: 5)
                        .scaleEffect(0.5)
                }
            }
            .badge(badgeView)
            .transition(.push(from: .trailing))
            .animation(.easeInOut, value: badgeView)
            #if hasAttribute(bouncy)
                .animation(.bouncy, value: packageItem.isTagged)
            #else
                .animation(.interpolatingSpring(stiffness: 80, damping: 10), value: packageItem.isTagged)
            #endif
        }
    }
}
