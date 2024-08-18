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
    @ObservedObject var packageDetails: BrewPackageDetails

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

                if packageDetails.pinned
                {
                    Image(systemName: "pin.fill")
                        .help("package-details.pinned.help-\(package.name)")
                }
            }

            VStack(alignment: .leading, spacing: 5)
            {
                HStack(alignment: .center, spacing: 5)
                {
                    if packageDetails.installedAsDependency
                    {
                        if let packageDependents = packageDetails.dependents
                        {
                            if !packageDependents.isEmpty // This happens when the package was originally installed as a dependency, but the parent is no longer installed
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
                                        .controlSize(.mini)

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
}
