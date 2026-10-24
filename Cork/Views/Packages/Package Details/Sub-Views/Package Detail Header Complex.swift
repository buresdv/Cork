//
//  Package Detail Header Complex.swift
//  Cork
//
//  Created by David Bureš on 03.10.2023.
//

import CorkModels
import CorkShared
import FactoryKit
import SwiftUI

struct PackageDetailHeaderComplex: View
{
    @Injected(\.appConstants) var appConstants: AppConstants
    @InjectedObservable(\.appState) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    let package: BrewPackage

    var isInPreviewWindow: Bool

    @Bindable var packageDetails: BrewPackage.BrewPackageDetails

    let isLoadingDetails: Bool

    var body: some View
    {
        VStack(alignment: .leading, spacing: 5)
        {
            HStack(alignment: .firstTextBaseline, spacing: 5)
            {
                let packageVersionsToDisplay: [String] =
                {
                    if package.versions.isEmpty
                    {
                        appConstants.logger.debug("The package has no local version - will try to get it from the JSON")
                        
                        /// See if there are any versions to be gotten in the JSON
                        if !packageDetails.versionFromJSON.isEmpty
                        {
                            appConstants.logger.debug("Will replace missing local version with the version from JSON ")
                            return [packageDetails.versionFromJSON]
                        }
                        else
                        {
                            appConstants.logger.warning("There are no local or JSON versions for package \(package.name(withPrecision: .precise))")
                            return package.versions
                        }
                    }
                    else
                    {
                        appConstants.logger.debug("The package already has a local version - no need to do anything")
                        return package.versions
                    }
                    
                }()
                
                package.nameView(
                    withComponents: .boundVersion,
                    .installedVersions(packageVersionsToDisplay),
                    isExemptFromHighlighting: true
                )
                .font(.title)

                if let dynamicPinnedStatus = brewPackagesTracker.successfullyLoadedFormulae.filter({ $0.id == package.id }).first
                {
                    if dynamicPinnedStatus.isPinned
                    {
                        Image(systemName: "pin.fill")
                            .help("package-details.pinned.help-\(package.name(withPrecision: .precise))")
                    }
                }
            }

            VStack(alignment: .leading, spacing: 5)
            {
                HStack(alignment: .center, spacing: 5)
                {
                    if !isInPreviewWindow
                    {
                        packageDetailsPill
                    }

                    PackageDeprecationViewMinifiedDisplay(
                        isDeprecated: packageDetails.deprecated,
                        deprecationReason: packageDetails.deprecationReason
                    )

                    PackageCaveatMinifiedDisplayView(caveats: packageDetails.caveats)
                }

                if !isLoadingDetails
                {
                    if let packageDescription = packageDetails.description
                    {
                        Text(packageDescription)
                            .font(.subheadline)
                    }
                    else
                    {
                        NoDescriptionProvidedView()
                    }
                }
            }
        }
    }

    @ViewBuilder
    var packageDetailsPill: some View
    {
        if packageDetails.outdated
        {
            StatusPill(localizedText: "package-details.outdated", systemImage: "clock", color: .teal)
        }
    }
}
