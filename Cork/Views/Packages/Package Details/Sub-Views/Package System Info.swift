//
//  Package System Info.swift
//  Cork
//
//  Created by David Bureš on 28.09.2023.
//

import SwiftUI

struct PackageSystemInfo: View
{
    let package: BrewPackage

    @State private var isShowingCaskSizeHelpPopover: Bool = false

    var body: some View
    {
        if let installedOnDate = package.installedOn // Only show the "Installed on" date for packages that are actually installed
        {
            Section
            {
                LabeledContent
                {
                    Text(installedOnDate.formatted(.packageInstallationStyle))
                } label: {
                    Text("package-details.install-date")
                }

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
    }
}
