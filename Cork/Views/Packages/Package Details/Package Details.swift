//
//  Package Details.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI
import SwiftyJSON

class SelectedPackageInfo: ObservableObject
{
    @Published var contents: String?
}

struct PackageDetailView: View
{
    @AppStorage("caveatDisplayOptions") var caveatDisplayOptions: PackageCaveatDisplay = .full

    @State var package: BrewPackage

    @EnvironmentObject var brewData: BrewDataStorage

    @StateObject var packageInfo: SelectedPackageInfo

    @EnvironmentObject var appState: AppState

    @State private var description: String = ""
    @State private var homepage: URL = .init(string: "https://google.com")!
    @State private var tap: String = ""
    @State private var installedAsDependency: Bool = false
    @State private var packageDependents: [String]? = nil
    @State private var dependencies: [BrewPackageDependency]? = nil
    @State private var outdated: Bool = false
    @State private var caveats: String? = nil
    @State private var pinned: Bool = false

    @State private var isShowingExpandedCaveats: Bool = false
    @State private var canExpandCaveats: Bool = false

    @State private var isShowingCaveatPopover: Bool = false
    @State private var isShowingDependencies: Bool = false
    @State var isShowingPopover: Bool = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 15)
        {
            VStack(alignment: .leading, spacing: 5)
            {
                HStack(alignment: .firstTextBaseline, spacing: 5)
                {
                    Text(package.name)
                        .font(.title)
                    Text("v. \(returnFormattedVersions(package.versions))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if pinned
                    {
                        Image(systemName: "pin.fill")
                            .help("\(package.name) is pinned. It will not be updated.")
                    }
                }

                VStack(alignment: .leading, spacing: 5)
                {
                    HStack(alignment: .center, spacing: 5)
                    {
                        if installedAsDependency
                        {
                            if let packageDependents
                            {
                                if packageDependents.count != 0 // This happens when the package was originally installed as a dependency, but the parent is no longer installed
                                {
                                    OutlinedPillText(text: "Dependency of \(packageDependents.joined(separator: ", "))", color: .secondary)
                                }
                            }
                            else
                            {
                                OutlinedPill(content: {
                                    HStack(alignment: .center, spacing: 5)
                                    {
                                        ProgressView()
                                            .scaleEffect(0.3, anchor: .center)
                                            .frame(width: 5, height: 5)

                                        Text("Loading Dependants...")
                                    }
                                }, color: Color(nsColor: NSColor.tertiaryLabelColor))
                            }
                        }
                        if outdated
                        {
                            OutlinedPillText(text: "Outdated", color: .orange)
                        }
                        if let caveats
                        {
                            if !caveats.isEmpty
                            {
                                if caveatDisplayOptions == .mini
                                {
                                    OutlinedPillText(text: "Has caveats 􀅴", color: .indigo)
                                        .onTapGesture
                                        {
                                            isShowingCaveatPopover.toggle()
                                        }
                                        .popover(isPresented: $isShowingCaveatPopover)
                                        {
                                            Text(.init(caveats.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n\n", with: "\n")))
                                                .textSelection(.enabled)
                                                .lineSpacing(5)
                                                .padding()
                                                .help("Click to see caveats")
                                        }
                                }
                            }
                        }
                    }

                    if packageInfo.contents != nil
                    {
                        if !description.isEmpty
                        {
                            Text(description)
                                .font(.subheadline)
                        }
                        else
                        {
                            HStack(alignment: .center, spacing: 10)
                            {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.yellow)
                                Text("\(package.name) has no description")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }

            if packageInfo.contents == nil
            {
                HStack(alignment: .center)
                {
                    VStack(alignment: .center)
                    {
                        ProgressView
                        {
                            Text("Loading package info...")
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            else
            {
                VStack(alignment: .leading, spacing: 10)
                {
                    Text("Info")
                        .font(.title2)

                    if let caveats
                    {
                        if !caveats.isEmpty
                        {
                            if caveatDisplayOptions == .full
                            {
                                GroupBox
                                {
                                    HStack(alignment: .top, spacing: 10)
                                    {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundColor(.yellow)

                                        /// Remove the last newline from the text if there is one, and replace all double newlines with a single newline
                                        VStack(alignment: .leading, spacing: 5)
                                        {
                                            let text = Text(
                                                .init(
                                                    caveats
                                                        .trimmingCharacters(in: .whitespacesAndNewlines)
                                                        .replacingOccurrences(of: "\n\n", with: "\n")
                                                )
                                            )
                                            .lineSpacing(5)

                                            text
                                                .textSelection(.enabled)
                                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                                .lineLimit(isShowingExpandedCaveats ? nil : 2)
                                                .background
                                                {
                                                    ViewThatFits(in: .vertical)
                                                    {
                                                        text.hidden()
                                                        Color.clear.onAppear { canExpandCaveats = true }
                                                    }
                                                }

                                            if canExpandCaveats
                                            {
                                                Button
                                                {
                                                    withAnimation
                                                    {
                                                        isShowingExpandedCaveats.toggle()
                                                    }
                                                } label: {
                                                    Text(isShowingExpandedCaveats ? "Collapse" : "Expand")
                                                }
                                                .padding(.top, 5)
                                            }
                                        }
                                    }
                                    .padding(2)
                                }
                            }
                        }
                    }

                    GroupBox
                    {
                        Grid(alignment: .leading, horizontalSpacing: 20)
                        {
                            GridRow(alignment: .firstTextBaseline)
                            {
                                Text("Tap")
                                Text(tap)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Divider()

                            GridRow(alignment: .top)
                            {
                                Text("Type")
                                if package.isCask
                                {
                                    Text("Cask")
                                }
                                else
                                {
                                    Text("Formula")
                                }
                            }

                            Divider()

                            GridRow(alignment: .top)
                            {
                                Text("Homepage")
                                Link(destination: homepage)
                                {
                                    Text(homepage.absoluteString)
                                }
                            }
                        }
                    }

                    if let dependencies
                    {
                        GroupBox
                        {
                            VStack
                            {
                                DisclosureGroup("Dependencies", isExpanded: $isShowingDependencies)
                                {}
                                .disclosureGroupStyle(NoPadding())

                                if isShowingDependencies
                                {
                                    DependencyList(dependencies: dependencies)
                                }
                            }
                        }
                    }

                    if let installedOnDate = package.installedOn // Only show the "Installed on" date for packages that are actually installed
                    {
                        GroupBox
                        {
                            Grid(alignment: .leading, horizontalSpacing: 20)
                            {
                                GridRow(alignment: .top)
                                {
                                    Text("Installed On")
                                    Text(installedOnDate.formatted(.packageInstallationStyle))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }

                                if let packageSize = package.sizeInBytes
                                {
                                    Divider()

                                    GridRow(alignment: .top)
                                    {
                                        Text("Size")

                                        HStack
                                        {
                                            Text(packageSize.formatted(.byteCount(style: .file)))

                                            if package.isCask
                                            {
                                                HelpButton
                                                {
                                                    isShowingPopover.toggle()
                                                }
                                                .help("Why is the size so small?")
                                                .popover(isPresented: $isShowingPopover)
                                                {
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
                if packageInfo.contents != nil
                {
                    HStack
                    {
                        if !package.isCask
                        {
                            Button
                            {
                                Task
                                {
                                    pinned.toggle()

                                    await pinAndUnpinPackage(package: package, pinned: pinned)
                                }
                            } label: {
                                Text(pinned ? "Unpin from version \(package.versions.joined())" : "Pin to version \(package.versions.joined())")
                            }
                        }

                        Spacer()

                        HStack(spacing: 15)
                        {
                            UninstallationProgressWheel()

                            Button(role: .destructive)
                            {
                                Task
                                {
                                    try await uninstallSelectedPackage(package: package, brewData: brewData, appState: appState)
                                }
                            } label: {
                                Text("Uninstall \(package.name)")
                            }
                        }
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
                if !package.isCask
                {
                    packageInfo.contents = await shell(AppConstants.brewExecutablePath.absoluteString, ["info", "--json=v2", package.name]).standardOutput
                }
                else
                {
                    packageInfo.contents = await shell(AppConstants.brewExecutablePath.absoluteString, ["info", "--json=v2", "--cask", package.name]).standardOutput
                }

                let parsedJSON: JSON = try parseJSON(from: packageInfo.contents!)

                description = getPackageDescriptionFromJSON(json: parsedJSON, package: package)
                homepage = getPackageHomepageFromJSON(json: parsedJSON, package: package)
                tap = getPackageTapFromJSON(json: parsedJSON, package: package)
                installedAsDependency = getIfPackageWasInstalledAsDependencyFromJSON(json: parsedJSON, package: package) ?? false
                outdated = getIfPackageIsOutdated(json: parsedJSON, package: package)
                caveats = getCaveatsFromJSON(json: parsedJSON, package: package)
                pinned = getPinStatusFromJSON(json: parsedJSON, package: package)
                
                if let packageDependencies = getPackageDependenciesFromJSON(json: parsedJSON, package: package)
                {
                    dependencies = packageDependencies
                }

                if installedAsDependency
                {
                    async let packageDependentsRaw: String = await shell(AppConstants.brewExecutablePath.absoluteString, ["uses", "--installed", package.name]).standardOutput

                    packageDependents = await packageDependentsRaw.components(separatedBy: "\n").dropLast()

                    print("Package dependents: \(String(describing: packageDependents))")
                }
            }
        }
        .onDisappear
        {
            packageInfo.contents = nil
        }
    }
}
