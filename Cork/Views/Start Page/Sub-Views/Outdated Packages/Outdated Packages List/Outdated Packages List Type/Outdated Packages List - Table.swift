//
//  Outdated Packages List - Table.swift
//  Cork
//
//  Created by David Bureš - P on 06.01.2026.
//

import SwiftUI
import Defaults
import CorkModels

struct OutdatedPackagesList_Table: View
{
    // TODO: Pretty much all these properties shared with the List version of this. Find a way to merge them
    
    @Environment(OutdatedPackagesTracker.self) var outdatedPackagesTracker: OutdatedPackagesTracker
    
    let packageUpdatingType: OutdatedPackage.PackageUpdatingType
    
    /// Filter out those relevant packages for this context form the tracker
    var relevantPackages: Set<OutdatedPackage>
    {
        switch packageUpdatingType
        {
        case .homebrew:
            return outdatedPackagesTracker.packagesManagedByHomebrew
        case .selfUpdating:
            return outdatedPackagesTracker.packagesThatUpdateThemselves
        }
    }
    
    /// Check whether all relevant packages are deselected
    var areAnyRelevantPackagesSelected: Bool
    {
        !relevantPackages.filter({ $0.isMarkedForUpdating }).isEmpty
    }
    
    var body: some View
    {
        Table(of: OutdatedPackage.self)
        {
            TableColumn("start-page.updates.action")
            { outdatedPackage in
                Toggle(isOn: Bindable(outdatedPackage).isMarkedForUpdating) {
                    EmptyView()
                }
            }
            .width(45)

            TableColumn("package-details.dependencies.results.name", value: \.package.name)

            TableColumn("start-page.updates.installed-version")
            { outdatedPackage in
                Text(outdatedPackage.installedVersions.formatted(.list(type: .and)))
            }

            TableColumn("start-page.updates.newest-version")
            { outdatedPackage in
                Text(outdatedPackage.newerVersion)
            }

            TableColumn("package-details.type")
            { outdatedPackage in
                Text(outdatedPackage.package.type.description)
            }

        } rows: {
            ForEach(relevantPackages.sorted(by: { $0.package.installedOn! < $1.package.installedOn! }))
            { outdatedPackage in
                TableRow(outdatedPackage)
                    .contextMenu
                    {
                        PreviewPackageButton(packageToPreview: .init(
                            name: outdatedPackage.package.name,
                            type: outdatedPackage.package.type,
                            installedIntentionally: outdatedPackage.package.installedIntentionally)
                        )
                    }
            }
        }
        .tableStyle(.bordered)
    }
}
