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
            GroupBox
            {
                GridRow(alignment: .top)
                {
                    Text("package-details.install-date")
                    Text(installedOnDate.formatted(.packageInstallationStyle))
                }

                if let packageSize = package.sizeInBytes
                {
                    Divider()

                    GridRow(alignment: .top)
                    {
                        Text("package-details.size")

                        HStack
                        {
                            Text(packageSize.formatted(.byteCount(style: .file)))

                            if package.isCask
                            {
                                HelpButton
                                {
                                    isShowingCaskSizeHelpPopover.toggle()
                                }
                                .help("package-details.size.help")
                                .popover(isPresented: $isShowingCaskSizeHelpPopover)
                                {
                                    VStack(alignment: .leading, spacing: 10)
                                    {
                                        Text("package-details.size.help.title")
                                            .font(.headline)
                                        Text("package-details.size.help.body-1")
                                        Text("package-details.size.help.body-2")
                                    }
                                    .padding()
                                    .frame(width: 300, alignment: .center)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
