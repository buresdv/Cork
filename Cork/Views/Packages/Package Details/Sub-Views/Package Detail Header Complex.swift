//
//  Package Detail Header Complex.swift
//  Cork
//
//  Created by David Bureš on 03.10.2023.
//

import SwiftUI
import CorkShared
import CorkModels
import FactoryKit

struct PackageDetailHeaderComplex: View
{    
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
                SanitizedPackageName(package: package, shouldShowVersion: false)
                    .font(.title)
                
                if !package.versions.isEmpty
                {
                    Text("v. \(package.getFormattedVersions())")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let dynamicPinnedStatus = brewPackagesTracker.successfullyLoadedFormulae.filter({ $0.id == package.id }).first {
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
            OutlinedPillText(text: "package-details.outdated", color: .teal)
        }
    }
}
