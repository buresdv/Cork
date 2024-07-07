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
                LabeledContent {
                    Text(installedOnDate.formatted(.packageInstallationStyle))
                } label: {
                    Text("package-details.install-date")
                }

                if let packageSize = package.sizeInBytes
                {
                    LabeledContent {
                        HStack
                        {
                            Text(packageSize.formatted(.byteCount(style: .file)))

                            if package.type == .cask
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
                                        Text("package-details.size.help")
                                            .font(.headline)
                                        Text("package-details.size.help.body-1")
                                        Text("package-details.size.help.body-2")
                                    }
                                    .multilineTextAlignment(.leading)
                                    .padding()
                                    .frame(width: 300)
                                }
                            }
                        }
                    } label: {
                        Text("package-details.size")
                    }
                }
            }
        }
    }
}
