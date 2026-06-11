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

    enum PackageDependantsDisplayStage: Equatable
    {
        case loadingDependants, showingDependants(dependantsToShow: [MinimalHomebrewPackage]), noDependantsToShow
    }

    let packageDetails: BrewPackage.BrewPackageDetails

    @State private var isDependantsListExpanded: Bool = false
    @State private var dependantsSearchText: String = ""

    private var dependantsToShow: [MinimalHomebrewPackage]
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
                                dependant.contextMenu(using: dependant)
                                Text("DEBUG")
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
