//
//  Package Detail Header Complex.swift
//  Cork
//
//  Created by David Bureš on 03.10.2023.
//

import SwiftUI
import CorkShared

struct PackageDetailHeaderComplex: View
{
    enum PackageDependantsDisplayStage: Equatable
    {
        case loadingDependants, showingDependants(dependantsToShow: [String]), noDependantsToShow
    }
    
    @Environment(AppState.self) var appState: AppState
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker
    
    let package: BrewPackage
    
    var isInPreviewWindow: Bool
    
    @Bindable var packageDetails: BrewPackageDetails

    let isLoadingDetails: Bool
    
    @Namespace var packageDependantsAnimationNamespace: Namespace.ID
    
    /// Controls whether the pill for showing dependants is shown
    var packageDependantsDisplayStage: PackageDependantsDisplayStage
    {
        if packageDetails.installedAsDependency
        {
            if let dependants = packageDetails.dependents
            {
                if dependants.isEmpty // This happens when the package was originally installed as a dependency, but the parent is no longer installed
                {
                    return .noDependantsToShow
                }
                else
                {
                    return .showingDependants(dependantsToShow: dependants)
                }
            }
            else
            {
                return .loadingDependants
            }
        }
        else
        {
            return .noDependantsToShow
        }
    }
    
    var packageDependantsPillColor: Color
    {
        switch self.packageDependantsDisplayStage {
        case .loadingDependants:
            return .init(nsColor: NSColor.tertiaryLabelColor)
        case .showingDependants:
            return .secondary
        case .noDependantsToShow:
            return .clear
        }
    }

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
                            .help("package-details.pinned.help-\(package.name)")
                    }
                }
            }

            VStack(alignment: .leading, spacing: 5)
            {
                HStack(alignment: .center, spacing: 5)
                {
                    if !isInPreviewWindow
                    {
                        
                        dependantsPill
                        
                        packageDetailsPill
                    }
                    
                    PackageDeprecationViewMinifiedDisplay(
                        isDeprecated: packageDetails.deprecated,
                        deprecationReason: packageDetails.deprecationReason
                    )

                    PackageCaveatMinifiedDisplayView(caveats: packageDetails.caveats)
                }
                .animation(appState.enableExtraAnimations ? .interpolatingSpring : .none, value: packageDependantsDisplayStage)

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
    var dependantsPill: some View
    {
        if packageDetails.installedAsDependency
        {
            
            OutlinedPill(content: {
                switch packageDependantsDisplayStage
                {
                case .loadingDependants:
                    HStack(alignment: .center, spacing: 5)
                    {
                        ProgressView()
                            .controlSize(.mini)
                        
                        Text("package-details.dependants.loading")
                            .matchedGeometryEffect(id: "dependantsPillContents", in: packageDependantsAnimationNamespace)
                    }
                case .showingDependants(let dependantsToShow):
                    Text("package-details.dependants.dependency-of-\(dependantsToShow.formatted(.list(type: .and)))")
                        .matchedGeometryEffect(id: "dependantsPillContents", in: packageDependantsAnimationNamespace)
                case .noDependantsToShow:
                    EmptyView()
                }
            }, color: packageDependantsPillColor)
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
