//
//  Package Details.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI

class SelectedPackageInfo: ObservableObject {
    @Published var contents: String?
}

struct PackageDetailView: View {
    @State var package: BrewPackage

    @State var isCask: Bool

    @State var brewData: BrewDataStorage

    @StateObject var packageInfo: SelectedPackageInfo

    @State private var description: String = ""
    @State private var homepage: String = ""
    @State private var tap: String = ""

    @State var isShowingPopover: Bool = false
    var notInstalledInSameFolderText = Text(
        String(
            localized: "casks_not_installed_in_same_folder_as_formulae_error_text"
        )
    )
    var noAccessToApplicationsFolderText = Text(
        String(
            localized: "no_access_to_applications_directory_error_text"
        )
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(package.name)
                        .font(.title)
                    Text("v. \(returnFormattedVersions(package.versions))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                if packageInfo.contents != nil {
                    Text(description)
                        .font(.subheadline)
                }
            }

            if packageInfo.contents == nil {
                LoadingView()
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Package Info")
                        .font(.title2)

                    GroupBox {
                        Grid(alignment: .leading) {
                            GridRow(alignment: .top) {
                                Text("Tap")
                                Text(tap)
                            }

                            Divider()

                            GridRow(alignment: .top) {
                                Text("Homepage")
                                Text(.init(homepage))
                            }
                        }

                    }

                    // Only show the "Installed on" date for packages that are actually installed
                    if let installedOnDate = package.installedOn {
                        GroupBox {
                            Grid(alignment: .leading) {
                                GridRow(alignment: .top) {
                                    Text("Installed On")
                                    Text(package.convertDateToPresentableFormat(date: installedOnDate))
                                }
                                if let packageSize = package.sizeInBytes {
                                    Divider()
                                    GridRow(alignment: .top) {
                                        Text("Size")
                                        HStack {
                                            Text(package.convertSizeToPresentableFormat(size: packageSize))

                                            if isCask {
                                                HelpButton {
                                                    isShowingPopover.toggle()
                                                }
                                                .help("Why is the size so small?")
                                                .popover(isPresented: $isShowingPopover) {
                                                    VStack(alignment: .leading, spacing: 10) {
                                                        Text("Why is the size so small?")
                                                            .font(.headline)

                                                        notInstalledInSameFolderText
                                                        noAccessToApplicationsFolderText
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
            // Only show the uninstall button for packages that are actually installed
            if package.installedOn != nil {
                HStack {
                    Spacer()
                    Button(role: .destructive) {
                        Task {
                            await uninstallSelectedPackages(
                                packages: [package.name], isCask: isCask, brewData: brewData
                            )
                        }
                    } label: {
                        /// If the package is cask, show "Uninstall Cask". If it's not, show "Uninstall Formula"
                        Text("Uninstall \(isCask ? "Cask" : "Formula")")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .onAppear {
            Task {
                if !isCask {
                    packageInfo.contents = await shell("/opt/homebrew/bin/brew", ["info", "--json", package.name])
                } else {
                    packageInfo.contents = await shell(
                        "/opt/homebrew/bin/brew", ["info", "--json=v2", "--cask", package.name]
                    )
                }

                description = extractPackageInfo(rawJSON: packageInfo.contents!, whatToExtract: .description)
                homepage = extractPackageInfo(rawJSON: packageInfo.contents!, whatToExtract: .homepage)
                tap = extractPackageInfo(rawJSON: packageInfo.contents!, whatToExtract: .tap)
            }
        }
        .onDisappear {
            packageInfo.contents = nil
        }
    }
}
