//
//  Package Detail Header Complex.swift
//  Cork
//
//  Created by David Bureš on 03.10.2023.
//

import SwiftUI

struct PackageDetailHeaderComplex: View
{
    let package: BrewPackage
    let packageDetails: BrewPackageDetails

    let packageDependents: [String]?
    
    let isLoadingDetails: Bool

    var body: some View
    {
        VStack(alignment: .leading, spacing: 5)
        {
            HStack(alignment: .firstTextBaseline, spacing: 5)
            {
                SanitizedPackageName(packageName: package.name, shouldShowVersion: false)
                    .font(.title)
                Text("v. \(package.getFormattedVersions())")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let pinned = packageDetails.pinned
                {
                    if pinned
                    {
                        Image(systemName: "pin.fill")
                            .help("package-details.pinned.help-\(package.name)")
                    }
                }
                else
                {
                    Image("custom.pin.fill.questionmark")
                        .help("package-details.pinned.undetermined.help-\(package.name)")
                }
            }

            VStack(alignment: .leading, spacing: 5)
            {
                HStack(alignment: .center, spacing: 5)
                {
                    if packageDetails.installedAsDependency
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
                    if packageDetails.outdated
                    {
                        OutlinedPillText(text: "package-details.outdated", color: .orange)
                    }

                    PackageCaveatMinifiedDisplayView(caveats: packageDetails.caveats)
                }

                if !isLoadingDetails
                {
                    if !packageDetails.description.isEmpty
                    {
                        Text(packageDetails.description)
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
    }
}
