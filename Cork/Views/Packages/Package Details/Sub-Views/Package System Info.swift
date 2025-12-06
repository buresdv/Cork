//
//  Package System Info.swift
//  Cork
//
//  Created by David Bureš on 28.09.2023.
//

import SwiftUI
import ApplicationInspector
import CorkModels

struct PackageSystemInfo: View
{
    let package: BrewPackage
    
    let caskExecutable: Application?

    @State private var isShowingCaskSizeHelpPopover: Bool = false

    var body: some View
    {
        if let installedOnDate = package.installedOn // Only show the "Installed on" date for packages that are actually installed
        {
            Section
            {
                caskInstalledAsLine
                
                installedOnDateLine(installedOnDate)

                packageSizeLine(package.sizeInBytes)
            }
        }
    }
    
    @ViewBuilder
    var caskInstalledAsLine: some View
    {
        
        if let caskExecutable
        {
            LabeledContent
            {
                AppIconDisplay(
                    displayType: .asIconWithAppNameDisplayed(
                        usingApp: caskExecutable,
                        namePosition: .besideAppIcon
                    ),
                    allowRevealingInFinderFromIcon: true
                )
            } label: {
                Text("package-details.installed-as")
            }
        }
    }
    
    @ViewBuilder
    func installedOnDateLine(_ installedOnDate: Date) -> some View
    {
        LabeledContent
        {
            Text(installedOnDate.formatted(.packageInstallationStyle))
        } label: {
            Text("package-details.install-date")
        }
    }
    
    @ViewBuilder
    func packageSizeLine(_ packageSize: Int64?) -> some View
    {
        if let packageSize = package.sizeInBytes
        {
            LabeledContent
            {
                Text(packageSize.formatted(.byteCount(style: .file)))
            } label: {
                Text("package-details.size")
            }
        }
    }
}
