//
//  Outdated Packages List Row Button.swift
//  Cork
//
//  Created by David Bureš - P on 06.01.2026.
//

import CorkModels
import Defaults
import SwiftUI

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
    }

    // MARK: - Various types of outdated package displays

    @ViewBuilder
    var outdatedPackageDetails_none: some View
    {
        outdatedPackage.package.nameView(withComponents: .boundVersion)
    }

    @ViewBuilder
    var outdatedPackageDetails_versionOnly: some View
    {
        HStack(alignment: .center)
        {
            outdatedPackage.package.nameView(withComponents: .boundVersion)

            HStack(alignment: .center)
            {
                let installedVersions: String = outdatedPackage.installedVersions.formatted(.list(type: .and))
                let newerVersion: String = outdatedPackage.newerVersion

                let pillForegroundColor: NSColor = .secondaryLabelColor
                let pillBackgroundColor: NSColor = .secondarySystemFill

                if showOldVersionsInOutdatedPackageList
                {
                    Label("\(installedVersions) → \(newerVersion)", systemImage: "arrow.up")
                        .labelStyle(
                            .pill(
                                color: .init(
                                    text: .init(nsColor: pillForegroundColor),
                                    background: .init(nsColor: pillBackgroundColor)
                                ),
                                iconStyle: .iconIsHidden
                            )
                        )
                }
                else
                {
                    Label("\(newerVersion)", systemImage: "arrow.up")
                        .labelStyle(
                            .pill(
                                color: .init(
                                    text: .init(nsColor: pillForegroundColor),
                                    background: .init(nsColor: pillBackgroundColor)
                                ),
                                iconStyle: .iconIsHidden
                            )
                        )
                }
            }
        }
    }
}
