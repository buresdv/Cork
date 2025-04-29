//
//  Search Result Row.swift
//  Cork
//
//  Created by David Bureš on 12.02.2023.
//

import CorkShared
import SwiftUI

struct SearchResultRow: View, Sendable
{
    @AppStorage("showDescriptionsInSearchResults") var showDescriptionsInSearchResults: Bool = false
    @AppStorage("showCompatibilityWarning") var showCompatibilityWarning: Bool = true

    @EnvironmentObject var brewData: BrewDataStorage

    let searchedForPackage: BrewPackage
    let context: Self.Context

    @State private var description: String?
    @State private var isCompatible: Bool?

    @State private var isLoadingDescription: Bool = true
    @State private var descriptionParsingFailed: Bool = false

    @State private var selectedVersion: String = ""

    var packageHasMultipleInstallableVersion: Bool
    {
        if searchedForPackage.versions.count > 1
        {
            return true
        }
        else
        {
            return false
        }
    }

    /// Checks if this package is already installed.
    /// # Returns
    /// - `isInstalled`: Whether this package, or another version of this package, is already installed
    /// - `installedPackage`: The already installed version of this package. Must be returned for precise installed version checking
    var isPackageAlreadyInstalled: (isInstalled: Bool, overlappingVersions: [String]?)
    {
        /// Whether this package is already installed
        var isInstalled: Bool = false

        /// The already installed version of this package from the tracker
        var installedPackage: BrewPackage?

        switch searchedForPackage.type
        {
        case .formula:
            if brewData.successfullyLoadedFormulae.contains(where: { $0.name == searchedForPackage.name })
            {
                isInstalled = true

                installedPackage = brewData.successfullyLoadedFormulae.filter { $0.name == searchedForPackage.name }.first
            }
        case .cask:
            if brewData.successfullyLoadedCasks.contains(where: { $0.name == searchedForPackage.name })
            {
                isInstalled = true

                installedPackage = brewData.successfullyLoadedCasks.filter { $0.name == searchedForPackage.name }.first
            }
        }

        if let installedPackage
        {
            let overlappingVersions: [String]? = {
                /// Double-check that the package we want to install actually has mutliple installable versions
                guard packageHasMultipleInstallableVersion == true
                else
                {
                    AppConstants.shared.logger.log("Searched-for package \(searchedForPackage.name, privacy: .public) has no multiple installable versions (was expecting a list of multiple installable versions, but there is only one installable versionn)")
                    return nil
                }

                /// Check which Homebrew version of this package is already installed
                guard let installedVersion: String = installedPackage.homebrewVersion
                else
                {
                    AppConstants.shared.logger.warning("Searched-for package \(searchedForPackage.name, privacy: .public) has no defined Homebrew version (was expecting a Homebrew version, got nil instead")

                    return nil
                }

                AppConstants.shared.logger.info("Determined that the Homebrew version for installed package \(installedPackage.name) is \(installedVersion)")

                let availableVersionsToInstall: [String] = searchedForPackage.versions

                let installedVersionsAsSet: Set<String> = Set(arrayLiteral: installedVersion)
                let installableVersionsAsSet: Set<String> = Set(availableVersionsToInstall)

                let finalVersionIntersectionSet: Set<String> = installableVersionsAsSet.intersection(installedVersionsAsSet)

                AppConstants.shared.logger.info("Final version intersection set for package \(searchedForPackage.name): \(finalVersionIntersectionSet.formatted(.list(type: .and)), privacy: .public)")

                return Array(finalVersionIntersectionSet)
            }()

            return (isInstalled, overlappingVersions)
        }
        else
        {
            return (isInstalled, nil)
        }
    }

    var body: some View
    {
        VStack(alignment: .leading)
        {
            HStack(alignment: .center)
            {
                SanitizedPackageName(packageName: searchedForPackage.name, shouldShowVersion: packageHasMultipleInstallableVersion ? false : true)

                if packageHasMultipleInstallableVersion
                {
                    Picker(selection: $selectedVersion)
                    {
                        ForEach(searchedForPackage.versions, id: \.self)
                        { packageVersion in

                            var isThisVersionAlreadyInstalled: Bool
                            {
                                AppConstants.shared.logger.debug("Will try to determine if version \(packageVersion) of package \(searchedForPackage.name) is already installed and should be disabled")

                                guard let overlappingVersions = isPackageAlreadyInstalled.overlappingVersions
                                else
                                {
                                    AppConstants.shared.logger.debug("Package \(searchedForPackage.name) has no determinable overlapping versions (something in the function that determines whether a package is already installed got fucked)")

                                    return false
                                }

                                if overlappingVersions.contains(packageVersion)
                                {
                                    AppConstants.shared.logger.debug("Version \(packageVersion) of package \(searchedForPackage.name) is included in overlapping versions (overlapping versions array: \(overlappingVersions.formatted(.list(type: .and))) and will be disabled")

                                    return true
                                }
                                else
                                {
                                    AppConstants.shared.logger.debug("Version \(packageVersion) of package \(searchedForPackage.name) is not included in overlapping versions (overlapping versions array: \(overlappingVersions.formatted(.list(type: .and))) and will NOT be disabled")

                                    return false
                                }
                            }

                            if #available(macOS 14.0, *)
                            {
                                Text(packageVersion)
                                    .selectionDisabled(isThisVersionAlreadyInstalled)
                            }
                            else
                            {
                                Text(packageVersion)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } label: {
                        EmptyView()
                    }
                    .labelsHidden()
                    .controlSize(.small)
                    .fixedSize(horizontal: true, vertical: true)
                    .onAppear
                    {
                        self.selectedVersion = searchedForPackage.versions.first!
                    }
                }
                else
                {
                    Text(searchedForPackage.versions.formatted(.list(type: .and)))
                }

                switch context
                {
                case .topPackages:
                    Spacer()

                    if let downloadCount = searchedForPackage.downloadCount
                    {
                        Text("add-package.top-packages.list-item-\(downloadCount)")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }

                case .searchResults:
                    if isPackageAlreadyInstalled.isInstalled && !packageHasMultipleInstallableVersion
                    {
                        PillTextWithLocalizableText(localizedText: "add-package.result.already-installed")
                    }

                    if let isCompatible
                    {
                        if !isCompatible
                        {
                            if showCompatibilityWarning
                            {
                                Image(systemName: "exclamationmark.circle")
                                Text("add-package.result.not-optimized-for-\(AppConstants.shared.osVersionString.fullName)")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }

            if showDescriptionsInSearchResults
            {
                if !descriptionParsingFailed
                { // Show this if the description got properly parsed
                    if isLoadingDescription
                    {
                        Text("add-package.result.loading-description")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    else
                    {
                        if let description
                        {
                            Text(description)
                                .font(.caption)
                        }
                        else
                        {
                            NoDescriptionProvidedView()
                        }
                    }
                }
                else
                { // Otherwise, tell the user the parsing failed
                    Text("add-package.result.loading-failed")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .tag(AddFormulaView.PackageSelectedToBeInstalled(package: searchedForPackage, version: selectedVersion.isEmpty ? nil : selectedVersion))
        .task
        {
            if showDescriptionsInSearchResults
            {
                AppConstants.shared.logger.info("\(searchedForPackage.name, privacy: .auto) came into view")

                if description == nil
                {
                    defer
                    {
                        isLoadingDescription = false
                    }

                    AppConstants.shared.logger.info("\(searchedForPackage.name, privacy: .auto) does not have its description loaded")

                    do
                    {
                        let searchedForPackage: BrewPackage = .init(name: searchedForPackage.name, type: searchedForPackage.type, installedOn: Date(), versions: [], sizeInBytes: nil, downloadCount: nil)

                        do
                        {
                            let parsedPackageInfo: BrewPackageDetails = try await searchedForPackage.loadDetails()

                            description = parsedPackageInfo.description

                            isCompatible = parsedPackageInfo.isCompatible
                        }
                        catch let descriptionParsingError
                        { // This happens when a package doesn' have any description at all, hence why we don't display an error
                            AppConstants.shared.logger.error("Failed while parsing searched-for package info: \(descriptionParsingError.localizedDescription, privacy: .public)")

                            descriptionParsingFailed = true
                        }
                    }
                }
                else
                {
                    AppConstants.shared.logger.info("\(searchedForPackage.name, privacy: .auto) already has its description loaded")
                }
            }
        }
    }

    enum Context
    {
        case searchResults
        case topPackages
    }
}
