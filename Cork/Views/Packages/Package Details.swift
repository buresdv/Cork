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
    @State private var tap: String = ""
    
    @State var isShowingPopover: Bool = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 15)
        {
            VStack(alignment: .leading, spacing: 5)
            {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(package.name)
                        .font(.title)
                    Text("v. \(returnFormattedVersions(package.versions))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                if packageInfo.contents != nil
                {
                    Text(description)
                        .font(.subheadline)
                }
            }

            if packageInfo.contents == nil
            {
                LoadingView()
            }
            else
            {
                VStack(alignment: .leading, spacing: 10)
                {
                    Text("Package Info")
                        .font(.title2)
                    
                    GroupBox
                    {
                        Grid(alignment: .leading)
                        {
                            GridRow(alignment: .top)
                            {
                                Text("Tap")
                                Text(tap)
                            }
                            
                            Divider()
                            
                            GridRow(alignment: .top)
                            {
                                Text("Homepage")
                                Text(.init(homepage))
                            }
                        }

                    }
                    
                    if let installedOnDate = package.installedOn // Only show the "Installed on" date for packages that are actually installed
                    {
                        GroupBox {
                            Grid(alignment: .leading)
                            {
                                GridRow(alignment: .top)
                                {
                                    Text("Installed On")
                                    Text(package.convertDateToPresentableFormat(date: installedOnDate))
                                }
                                
                                if let packageSize = package.sizeInBytes
                                {
                                    Divider()
                                    
                                    GridRow(alignment: .top)
                                    {
                                        Text("Size")
                                        
                                        HStack
                                        {
                                            Text(package.convertSizeToPresentableFormat(size: packageSize))
                                            
                                            if isCask {
                                                HelpButton {
                                                    isShowingPopover.toggle()
                                                }
                                                .help("Why is the size so small?")
                                                .popover(isPresented: $isShowingPopover) {
                                                    VStack(alignment: .leading, spacing: 10)
                                                    {
                                                        Text("Why is the size so small?")
                                                            .font(.headline)
                                                        Text("Casks are not installed into the same installation directory as Formulae. Casks are installed into the Applications directory.")
                                                        Text("Since Cork does not have access to your Applications directory, it cannot get the size of the actual app, only of the metadata associated with the Cask.")
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
                    packageInfo.contents = await shell("/opt/homebrew/bin/brew", ["info", "--json", package.name]).standardOutput
                }
                else
                {
                    packageInfo.contents = await shell("/opt/homebrew/bin/brew", ["info", "--json=v2", "--cask", package.name]).standardOutput
                }

                description = extractPackageInfo(rawJSON: packageInfo.contents!, whatToExtract: .description)
                homepage = extractPackageInfo(rawJSON: packageInfo.contents!, whatToExtract: .homepage)
                tap = extractPackageInfo(rawJSON: packageInfo.contents!, whatToExtract: .tap)
            }
        }
        .onDisappear
        {
            packageInfo.contents = nil
        }
    }
}
