//
//  Outdated Packages List Row Button.swift
//  Cork
//
//  Created by David Bureš - P on 06.01.2026.
//

import SwiftUI
import Defaults
import CorkModels

struct OutdatedPackageListBoxRow: View
{
    @Default(.outdatedPackageInfoDisplayAmount) var outdatedPackageInfoDisplayAmount
    @Default(.showOldVersionsInOutdatedPackageList) var showOldVersionsInOutdatedPackageList

    let outdatedPackage: OutdatedPackage

    @State private var isExpanded: Bool = false

    var body: some View
    {
        VStack(alignment: .leading)
        {
            switch outdatedPackageInfoDisplayAmount
            {
            case .none:
                outdatedPackageDetails_none
            case .versionOnly:
                outdatedPackageDetails_versionOnly
            case .all:
                EmptyView()
            }
        }
        .contextMenu
        {
            PreviewPackageButton(packageToPreview: .init(
                name: outdatedPackage.package.name,
                type: outdatedPackage.package.type,
                installedIntentionally: outdatedPackage.package.installedIntentionally
            ))
        }
    }

    // MARK: - Various types of outdated package displays

    @ViewBuilder
    var outdatedPackageDetails_none: some View
    {
        SanitizedPackageName(package: outdatedPackage.package, shouldShowVersion: true)
    }

    @ViewBuilder
    var outdatedPackageDetails_versionOnly: some View
    {
        HStack(alignment: .center)
        {
            SanitizedPackageName(package: outdatedPackage.package, shouldShowVersion: true)

            HStack(alignment: .center)
            {
                let installedVersions: String = outdatedPackage.installedVersions.formatted(.list(type: .and))
                let newerVersion: String = outdatedPackage.newerVersion
                
                let pillForegroundColor: NSColor = .secondaryLabelColor
                let pillBackgroundColor: NSColor = .quinaryLabel
                
                if showOldVersionsInOutdatedPackageList
                {
                    
                    PillText(text: "\(installedVersions) → \(newerVersion)", backgroundColor: pillBackgroundColor, textColor: pillForegroundColor)
                }
                else
                {
                    PillText(text: "\(newerVersion)", backgroundColor: pillBackgroundColor, textColor: pillForegroundColor)
                }
            }
        }
    }
}
