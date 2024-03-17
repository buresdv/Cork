//
//  Package Details.swift
//  Cork
//
//  Created by David Bureš on 03.07.2022.
//

import SwiftUI
import SwiftyJSON

struct PackageDetailView: View, Sendable
{
    let package: BrewPackage

    @EnvironmentObject var brewData: BrewDataStorage

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
    @State private var isShowingExpandedCaveats: Bool = false

    @State private var isLoadingDetails: Bool = true

    @State var isShowingPopover: Bool = false

    @State private var erroredOut: Bool = false

    private var isScrollingDisabled: Bool
    {
        if isShowingExpandedCaveats
        {
            return false
        }
        else if isShowingExpandedDependencies
        {
            return false
        }
        else
        {
            return true
        }
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 0)
        {
            if isLoadingDetails
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
                    FullSizeGroupedForm
                    {
                        BasicPackageInfoView(
                            package: package,
                            tap: tap,
                            homepage: homepage,
                            description: description,
                            pinned: pinned,
                            installedAsDependency: installedAsDependency,
                            packageDependents: packageDependents,
                            outdated: outdated,
                            caveats: caveats,
                            isLoadingDetails: isLoadingDetails,
                            isShowingExpandedCaveats: $isShowingExpandedCaveats
                        )

                        PackageDependencies(dependencies: dependencies, isDependencyDisclosureGroupExpanded: $isShowingExpandedDependencies)

                        PackageSystemInfo(package: package)
                    }
                    .scrollDisabled(isScrollingDisabled)
                }
            }

            Spacer()

            PackageModificationButtons(
                package: package,
                pinned: $pinned,
                isLoadingDetails: isLoadingDetails
            )
        }
        .frame(minWidth: 450, minHeight: 400, alignment: .topLeading)
        .task(priority: .userInitiated)
        {
            var packageInfoRaw: String?

            defer
            {
                if isLoadingDetails
                {
                    isLoadingDetails = false
                }

                packageInfoRaw = nil
            }

            if !package.isCask
            {
                packageInfoRaw = await shell(AppConstants.brewExecutablePath, ["info", "--json=v2", package.name]).standardOutput
            }
            else
            {
                packageInfoRaw = await shell(AppConstants.brewExecutablePath, ["info", "--json=v2", "--cask", package.name]).standardOutput
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

                isLoadingDetails = false

                if let packageDependencies = getPackageDependenciesFromJSON(json: parsedJSON, package: package)
                {
                    dependencies = packageDependencies
                }

                if installedAsDependency
                {
                    async let packageDependentsRaw: String = await shell(AppConstants.brewExecutablePath, ["uses", "--installed", package.name]).standardOutput

                    packageDependents = await packageDependentsRaw.components(separatedBy: "\n").dropLast()

                    AppConstants.logger.info("Package dependents: \(String(describing: packageDependents), privacy: .auto)")
                }
            }
            catch let packageInfoDecodingError
            {
                AppConstants.logger.error("Failed while parsing package info: \(packageInfoDecodingError, privacy: .public)")

                erroredOut = true
            }
        }
    }
}
