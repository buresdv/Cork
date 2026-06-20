//
//  Dependants List.swift
//  Cork
//
//  Created by David Bureš - P on 12.06.2026.
//

import CorkModels
import Defaults
import SwiftUI

struct DependantsList: View
{
    @Default(.showSearchFieldForDependenciesInPackageDetails) var showSearchFieldForDependenciesInPackageDetails: Bool
    
    @Environment(BrewPackagesTracker.self) var brewPackagesTracker: BrewPackagesTracker

    enum PackageDependantsDisplayStage: Equatable
    {
        case loadingDependants, showingDependants(dependantsToShow: [BrewPackage]), noDependantsToShow
    }

    let packageDetails: BrewPackage.BrewPackageDetails

    @State private var isDependantsListExpanded: Bool = false
    @State private var dependantsSearchText: String = ""

    private var dependantsToShow: [BrewPackage]
    {
        switch packageDependantsDisplayStage
        {
        case .loadingDependants:
            return .init()
        case .showingDependants(let dependants):
            if dependantsSearchText.isEmpty
            {
                return dependants
            }
            else
            {
                return dependants.filter { $0.name(withPrecision: .precise).localizedCaseInsensitiveContains(dependantsSearchText) }
            }
        case .noDependantsToShow:
            return .init()
        }
    }

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
                    let dependantNames: Set<BrewPackageName> = Set(dependants.map(\.internalName))
                    
                    let extractedFullPackages: [BrewPackage] = {
                        return brewPackagesTracker.successfullyLoadedFormulae.filter{ dependantNames.contains( $0.internalName ) }
                    }()
                    
                    return .showingDependants(dependantsToShow: extractedFullPackages)
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

    var body: some View
    {
        switch packageDependantsDisplayStage
        {
        case .loadingDependants:

            HStack(alignment: .center, spacing: 15)
            {
                ProgressView()

                Text("package-details.dependants.loading")
            }

        case .showingDependants(let dependants):
            DisclosureGroup(isExpanded: $isDependantsListExpanded)
            {
                VStack
                {
                    if showSearchFieldForDependenciesInPackageDetails
                    {
                        CustomSearchField(search: $dependantsSearchText, customPromptText: nil)
                    }

                    List(dependantsToShow)
                    { dependant in
                        dependant.nameView(withComponents: .boundVersion)
                            .contextMenu
                            {
                                dependant.contextMenu(builtInContent: .openPackageDetailButton)
                            }
                    }
                    .listStyle(.bordered(alternatesRowBackgrounds: true))
                }

            } label: {
                Text("package-details.dependants.\(dependants.count)")
            }

        case .noDependantsToShow:
            EmptyView()
        }
    }
}
