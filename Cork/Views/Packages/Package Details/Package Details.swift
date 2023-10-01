//
//  Package Details.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI
import SwiftyJSON

struct PackageDetailView: View
{
    @AppStorage("allowMoreCompleteUninstallations") var allowMoreCompleteUninstallations: Bool = false

    let package: BrewPackage

    @EnvironmentObject var brewData: BrewDataStorage

    @State var packageInfoRaw: String?

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var outdatedPackageTracker: OutdatedPackageTracker

    @State private var description: String = ""
    @State private var homepage: URL = .init(string: "https://google.com")!
    @State private var tap: String = ""
    @State private var installedAsDependency: Bool = false
    @State private var packageDependents: [String]? = nil
    @State private var dependencies: [BrewPackageDependency]? = nil
    @State private var outdated: Bool = false
    @State private var caveats: String? = nil
    @State private var pinned: Bool = false

    @State private var isShowingExpandedDependencies: Bool = false

    @State var isShowingPopover: Bool = false

    @State private var erroredOut: Bool = false

    var body: some View
    {
        VStack(alignment: .leading, spacing: 15)
        {
            VStack(alignment: .leading, spacing: 5)
            {
                HStack(alignment: .firstTextBaseline, spacing: 5)
                {
                    SanitizedPackageName(packageName: package.name, shouldShowVersion: false)
                        .font(.title)
                    Text("v. \(returnFormattedVersions(package.versions))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if pinned
                    {
                        Image(systemName: "pin.fill")
                            .help("package-details.pinned.help-\(package.name)")
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
                                    OutlinedPillText(text: "package-details.dependants.dependency-of-\(packageDependents.formatted(.list(type: .and)))", color: .secondary)
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

                                        Text("package-details.dependants.loading")
                                    }
                                }, color: Color(nsColor: NSColor.tertiaryLabelColor))
                            }
                        }
                        if outdated
                        {
                            OutlinedPillText(text: "package-details.outdated", color: .orange)
                        }

                        PackageCaveatMinifiedDisplayView(caveats: caveats)
                    }

                    if packageInfoRaw != nil
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
                                Text("package-details.description-none-\(package.name)")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }

            if packageInfoRaw == nil
            {
                HStack(alignment: .center)
                {
                    VStack(alignment: .center)
                    {
                        ProgressView
                        {
                            Text("package-details.contents.loading")
                        }
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            else
            {
                if erroredOut
                {
                    InlineFatalError(errorMessage: "alert.generic.couldnt-parse-json")
                }
                else
                {
                    VStack(alignment: .leading)
                    {
                        PackageCaveatFullDisplayView(caveats: caveats)

                        Text("package-details.info")
                            .font(.title2)

                        FullSizeGroupedForm
                        {
                            BasicPackageInfoView(package: package, tap: tap, homepage: homepage)

                            PackageDependencies(dependencies: dependencies, isDependencyDisclosureGroupExpanded: $isShowingExpandedDependencies)

                            PackageSystemInfo(package: package)
                        }
                        .scrollDisabled(!isShowingExpandedDependencies)
                    }
                }
            }

            Spacer()

            if let _ = package.installedOn // Only show the uninstall button for packages that are actually installed
            {
                if packageInfoRaw != nil
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
                                Text(pinned ? "package-details.action.unpin-version-\(package.versions.formatted(.list(type: .and)))" : "package-details.action.pin-version-\(package.versions.formatted(.list(type: .and)))")
                            }
                        }

                        Spacer()

                        HStack(spacing: 15)
                        {
                            UninstallationProgressWheel()
                            
                            if allowMoreCompleteUninstallations
                            {
                                Spacer()
                            }

                            if !allowMoreCompleteUninstallations
                            {
                                Button(role: .destructive)
                                {
                                    Task
                                    {
                                        try await uninstallSelectedPackage(
                                            package: package,
                                            brewData: brewData,
                                            appState: appState,
                                            outdatedPackageTracker: outdatedPackageTracker,
                                            shouldRemoveAllAssociatedFiles: false
                                        )
                                    }
                                } label: {
                                    Text("package-details.action.uninstall-\(package.name)")
                                }
                            }
                            else
                            {
                                Menu {
                                    Button(role: .destructive)
                                    {
                                        Task
                                        {
                                            try await uninstallSelectedPackage(
                                                package: package,
                                                brewData: brewData,
                                                appState: appState,
                                                outdatedPackageTracker: outdatedPackageTracker,
                                                shouldRemoveAllAssociatedFiles: true
                                            )
                                        }
                                    } label: {
                                        Text("package-details.action.uninstall-deep-\(package.name)")
                                    }
                                } label: {
                                    Text("package-details.action.uninstall-\(package.name)")
                                } primaryAction: {
                                    Task(priority: .userInitiated)
                                    {
                                        try! await uninstallSelectedPackage(
                                            package: package,
                                            brewData: brewData,
                                            appState: appState,
                                            outdatedPackageTracker: outdatedPackageTracker,
                                            shouldRemoveAllAssociatedFiles: false
                                        )
                                    }
                                }
                                .fixedSize()
                            }
                        }
                    }
                }
            }
        }
        .frame(minWidth: 450, minHeight: 400, alignment: .topLeading)
        .padding()
        .task(priority: .userInitiated)
        {
            if !package.isCask
            {
                packageInfoRaw = await shell(AppConstants.brewExecutablePath.absoluteString, ["info", "--json=v2", package.name]).standardOutput
            }
            else
            {
                packageInfoRaw = await shell(AppConstants.brewExecutablePath.absoluteString, ["info", "--json=v2", "--cask", package.name]).standardOutput
            }

            do
            {
                let parsedJSON: JSON = try parseJSON(from: packageInfoRaw!)

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
            catch let packageInfoDecodingError
            {
                print("Failed while parsing package info: \(packageInfoDecodingError)")

                erroredOut = true
            }
        }
    }
}
