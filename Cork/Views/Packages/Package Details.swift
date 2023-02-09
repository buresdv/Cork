//
//  Package Details.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

class SelectedPackageInfo: ObservableObject
{
    @Published var contents: String?
}

struct PackageDetailView: View
{
    @State var package: BrewPackage

    @State var isCask: Bool

    @State var brewData: BrewDataStorage

    @StateObject var packageInfo: SelectedPackageInfo

    @State private var description: String = ""
    @State private var homepage: String = ""

    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            VStack(alignment: .leading)
            {
                Text(package.name)
                    .font(.title)
                Text(returnFormattedVersions(package.versions))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            if packageInfo.contents == nil
            {
                LoadingView()
            }
            else
            {
                GroupBox
                {
                    Grid(alignment: .leading)
                    {
                        GridRow(alignment: .top)
                        {
                            Text("Description")
                            Text(description)
                        }

                        Divider()

                        GridRow(alignment: .top)
                        {
                            Text("Homepage")
                            Text(.init(homepage))
                        }

                        if let installedOnDate = package.installedOn // Only show the "Installed on" date for packages that are actually installed
                        {
                            Divider()

                            GridRow(alignment: .top)
                            {
                                Text("Installed On")
                                Text(package.convertDateToPresentableFormat(date: installedOnDate))
                            }
                        }
                    }

                } label: {
                    Text("Package Info")
                        .font(.headline)
                }
            }

            Spacer()

            if let _ = package.installedOn // Only show the uninstall button for packages that are actually installed
            {
                HStack
                {
                    Spacer()
                    Button(role: .destructive)
                    {
                        Task
                        {
                            await uninstallSelectedPackages(packages: [package.name], isCask: isCask, brewData: brewData)
                        }
                    } label: {
                        Text("Uninstall \(isCask ? "Cask" : "Formula")") /// If the package is cask, show "Uninstall Cask". If it's not, show "Uninstall Formula"
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .onAppear
        {
            Task
            {
                if !isCask
                {
                    packageInfo.contents = await shell("/opt/homebrew/bin/brew", ["info", "--json", package.name])
                }
                else
                {
                    packageInfo.contents = await shell("/opt/homebrew/bin/brew", ["info", "--json=v2", "--cask", package.name])
                }

                description = extractPackageInfo(rawJSON: packageInfo.contents!, whatToExtract: .description)
                homepage = extractPackageInfo(rawJSON: packageInfo.contents!, whatToExtract: .homepage)
            }
        }
        .onDisappear
        {
            packageInfo.contents = nil
        }
    }
}
